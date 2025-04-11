class UsersController < ApplicationController
  include ParamValidation
def create
  user_params = params.permit(:user_id, :name, :email).to_h
  # パラメータバリデーション
  return unless validate_required_keys!(:create, param_module: RequiredParams::User)

  # DB定義に合わせてパラメータ名変更
  user_params[:id] = user_params.delete(:user_id)

  # ユーザ作成
  user = User.create!(user_params)
  render json: { status: "success", user: user }, status: :created

  # エラーハンドリング
rescue => e
  Rails.logger.error("Unexpected error: #{e.class} - #{e.message}")
  render json: {
    status: "error",
    error: {
      code: "INTERNAL_SERVER_ERROR",
      message: "An unexpected error occurred."
    }
  }, status: :internal_server_error
end

def show
  user_id = params[:user_id]
  # パラメータバリデーション
  return unless validate_required_keys!(:show, param_module: RequiredParams::User)

  # ユーザ取得
  user = User.find_by(id: user_id)
  if user.nil?
    return render json: {
      status: "error",
      error: {
        code: "NOT_FOUND",
        message: "User not found"
      }
    }, status: :not_found
  end

  render json: { status: "success", user: user }, status: :ok

  # エラーハンドリング
rescue => e
  Rails.logger.error("Unexpected error: #{e.class} - #{e.message}")
  render json: {
    status: "error",
    error: {
      code: "INTERNAL_SERVER_ERROR",
      message: "An unexpected error occurred."
    }
  }, status: :internal_server_error
end
end
