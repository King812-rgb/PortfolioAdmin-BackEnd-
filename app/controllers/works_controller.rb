class WorksController < ApplicationController
  def create
    work_params = params.permit(
      :user_id, :title, :description, :tech_stack, :screenshot_url,
      :site_url, :github_url, :released_on, :is_published
    )

    work = Work.create!(work_params)

    render json: { status: "success", id: work.id }, status: :created

  rescue ActiveRecord::RecordInvalid => e
    render json: {
      status: "error",
      error: {
        code: "INVALID_PARAM",
        message: e.record.errors.full_messages.join(", ")
      }
    }, status: :bad_request

  rescue => e
    render json: {
      status: "error",
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "An unexpected error occurred."
      }
    }, status: :internal_server_error
  end

  def update
    work_params = params.permit(
      :id, :title, :description, :tech_stack, :screenshot_url,
      :site_url, :github_url, :released_on, :is_published, :user_id
    )
    missing_keys = []
    missing_keys << "id" if work_params[:id].blank?
    missing_keys << "user_id" if work_params[:user_id].blank?
    unless missing_keys.empty?
      raise ActionController::ParameterMissing, missing_keys.join(", ")
    end
    work = Work.find_by(id: work_params[:id], user_id: work_params[:user_id])
    if work.nil?
      return render json: {
        status: "error",
        error: {
          code: "NOT_FOUND",
          message: "Work not found"
        }
      }, status: :not_found
    end

    if work.update(work_params.except(:id, :user_id))
      render json: { status: "success", id: work.id }, status: :created
    else
      render json: {
        status: "error",
        error: {
          code: "INVALID_PARAM",
          message: work.errors.full_messages.join(",")
        }
      }, status: :bad_request
    end
  rescue ActionController::ParameterMissing => e
    render json: {
      status: "error",
      error: {
        code: "INVALID_PARAM",
        message: "Missing required parameters: #{e.param}"
      }
    }, status: :bad_request
  rescue  => e
    render json: {
      status: "error",
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "An unexpected error occurred: #{e.message}"
      }
    }, status: :internal_server_error
  end

  def destroy
    work_params = params.permit(:id, :user_id)
    missing_keys = []
    missing_keys << "id" if work_params[:id].blank?
    missing_keys << "user_id" if work_params[:user_id].blank?
    unless missing_keys.empty?
      raise ActionController::ParameterMissing, missing_keys.join(", ")
    end

    work = Work.find_by(id: work_params[:id].to_s, user_id: work_params[:user_id].to_s)
    if work.nil?
      return render json: {
        status: "error",
        error: {
          code: "NOT_FOUND",
          message: "Work not found"
        }
      }, status: :not_found
    end
    work.destroy!
    render json: { status: "success" }, status: :ok
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
    works = Work.where(user_id: user_id)
    render json: { status: "success", works: works }, status: :ok
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
