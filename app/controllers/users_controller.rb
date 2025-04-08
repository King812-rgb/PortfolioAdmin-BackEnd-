class UsersController < ApplicationController
def create
  user_params = params.permit(:user_id, :name, :email).to_h
  missing_keys = %i[user_id name email].select { |key| user_params[key].blank? }
  raise ActionController::ParameterMissing.new(missing_keys.join(", ")) if missing_keys.any?
  user_params[:id] = user_params.delete("user_id")
  user = User.create!(user_params)
  render json: { status: "success", user: user }, status: :created
rescue ActionController::ParameterMissing => e
  render json: {
    status: "error",
    error: {
      code: "INVALID_PARAM",
      message: "Missing required parameters: #{e.param}"
    }
  }, status: :bad_request
rescue => e
  render json: {
    status: "error",
    error: {
      code: "INTERNAL_SERVER_ERROR",
      message: "An unexpected error occurred: #{e.message}"
    }
  }, status: :internal_server_error
end

def show
  user_id = params[:user_id]
  raise ActionController::ParameterMissing, "user_id" if user_id.blank?
  user = User.where(id: user_id)
  render json: { status: "success", user: user }, status: :ok
rescue ActionController::ParameterMissing => e
  render json: {
    status: "error",
    error: {
      code: "INVALID_PARAM",
      message: "Missing required parameters: #{e.param}"
    }
  }, status: :bad_request
rescue => e
  render json: {
    status: "error",
    error: {
      code: "INTERNAL_SERVER_ERROR",
      message: "An unexpected error occurred: #{e.message}"
    }
  }, status: :internal_server_error
end
end
