module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    helper_method :authenticated?, :superuser?
  end

  private
    def authenticated?
      Current.user.present?
    end

    def superuser?
      Current.user&.superuser? || false
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path, alert: "Sign in to continue."
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def require_superuser
      unless authenticated?
        request_authentication
        return
      end

      redirect_to root_path, alert: "You are not authorized to do that." unless superuser?
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
