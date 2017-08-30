class ApplicationController < ActionController::Base
  before_action :authorize_api_key
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def authorize_api_key
    unless params[:api_key] == ENV.fetch('api_key')
      render json: { title: 'Unauthorized request', status: '401' }, status: :unauthorized
    end
  end
end
