class ApplicationController < ActionController::API
  before_action :authenticate_request!

  private

  def authenticate_request!
    auth_header = request.headers["Authorization"]
    token = auth_header&.split(" ")&.last

    unless token.present? && token == ENV["API_KEY"]
      render json: { status: "error", error: { code: "UNAUTHORIZED", message: "Invalid API key" } }, status: :unauthorized
    end
  end
end
