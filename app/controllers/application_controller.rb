class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include DeviseHackFakeSession
  include ActionController::Flash
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private

  def check_admin
    unless current_user&.admin?
      render_404
    end
  end

  def redirect_to_sign_in
    session[:request] = nil
    session[:request] = request.original_url

    flash[:failed] = "ログインしてください"
    redirect_to new_user_session_path, status: :see_other
  end

  def render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.message}" if e

    if request.xhr?
      render json: { error: '404 error' }, status: 404
    else
      format = params[:format] == :json ? :json : :html
      render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
    end
  end
end
