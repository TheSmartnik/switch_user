class SwitchUserController < ApplicationController

  before_filter :developer_modes_only

  def set_current_user
    send("#{SwitchUser.provider}_handle", params)
    redirect_to(request.env["HTTP_REFERER"] ? :back : root_path)
  end

  private
    def developer_modes_only
      render :text => "Permission Denied", :status => 403 unless Rails.env == "development"
    end

    def devise_handle(params)
      if params[:scope_id].blank?
        SwitchUser.available_users.keys.each do |s|
          warden.logout(s)
        end
      else
        scope, id = params[:scope_id].split('_')
        SwitchUser.available_users.keys.each do |s|
          if scope == s.to_s
            user = scope.classify.constantize.find(id)
            warden.set_user(user, :scope => scope)
          else
            warden.logout(s)
          end
        end
      end
    end

    def authlogic_handle(params)
      if params[:scope_id].blank?
        current_user_session.destroy
      else
        scope, id = params[:scope_id].split('_')
        SwitchUser.available_users.keys.each do |s|
          if scope == s.to_s
            user = scope.classify.constantize.find(id)
            UserSession.create(user)
          end
        end
      end
    end
end