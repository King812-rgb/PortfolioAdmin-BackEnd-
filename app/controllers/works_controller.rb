class WorksController < ApplicationController
  include ParamValidation

  def create
    work_params = params.permit(
      :user_id, :title, :description, :tech_stack, :screenshot_image_base64,
      :site_url, :github_url, :released_on, :is_published
    )

    # パラメータバリデーション
    return unless validate_required_keys!(:create, param_module: RequiredParams::Work)

    # 対象のユーザ存在チェック
    user = User.find_by(id: work_params[:user_id])
    if user.nil?
      return render json: {
        status: "error",
        error: {
          code: "NOT_FOUND",
          message: "User not found"
        }
      }, status: :not_found
    end

    # 画像デコード⇨S3キー生成⇨S3に画像アップロード⇨画像URLを保存
    decoded = ImageUtil.decode_base64_image(work_params[:screenshot_image_base64])
    key = S3ImageUtil.generate_s3_key(work_params[:title], decoded[:extension])
    url = S3ImageUtil.upload_image_to_s3(
      body: decoded[:body],
      key: key,
      content_type: decoded[:content_type]
    )
    work_params[:screenshot_url] = url

    # ワーク作成
    work = Work.create!(work_params.except(:screenshot_image_base64))

    render json: { status: "success", id: work.id }, status: :created

    # エラーハンドリング
  rescue ImageDecodeError => e
    Rails.logger.error("ImageDecodeError: #{e.message}")
    render json: {
      status: "error",
      error: {
       code: "INVALID_PARAM",
       message: "Failed to decode image."
       }
       }, status: :bad_request

  rescue S3UploadError => e
    Rails.logger.error("S3 upload failed: #{e.message}")
    render json: {
      status: "error",
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to upload image to S3."
        }
        }, status: :internal_server_error

  rescue => e
    puts e.message
    puts e.class
    Rails.logger.error("Unexpected error: #{e.class} - #{e.message}")
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
      :id, :title, :description, :tech_stack, :screenshot_image_base64,
      :site_url, :github_url, :released_on, :is_published, :user_id
    )

    # パラメータバリデーション
    return unless validate_required_keys!(:update, param_module: RequiredParams::Work)

    # 対象のワーク存在チェック
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
    old_url = work.screenshot_url

    # 画像デコード⇨S3キー生成⇨S3に画像アップロード⇨画像URLを保存
    decoded = ImageUtil.decode_base64_image(work_params[:screenshot_image_base64])
    key = S3ImageUtil.generate_s3_key(work_params[:title], decoded[:extension])
    new_url = S3ImageUtil.upload_image_to_s3(
      body: decoded[:body],
      key: key,
      content_type: decoded[:content_type]
    )
    work_params[:screenshot_url] = new_url

    # ワーク更新
    work.update!(work_params.except(:id, :user_id, :screenshot_image_base64))

    # 更新成功したらS3の古い画像を削除
    begin
      S3ImageUtil.delete_image_by_url(old_url)
    rescue S3DeleteError => e
      Rails.logger.warn("S3 delete failed: #{e.message}")
    end

    render json: { status: "success", id: work.id }, status: :created

    # エラーハンドリング
  rescue ImageDecodeError => e
    render json: {
      status: "error",
      error: {
       code: "INVALID_PARAM",
       message: "Failed to decode image."
       }
       }, status: :bad_request

  rescue S3UploadError => e
    Rails.logger.error("S3 upload failed: #{e.message}")
    render json: {
      status: "error",
      error: {
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to upload image to S3."
        }
        }, status: :internal_server_error

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

  def destroy
    work_params = params.permit(:id, :user_id)

    # パラメータバリデーション
    return unless validate_required_keys!(:destroy, param_module: RequiredParams::Work)

    # 対象のワーク存在チェック
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

    # ワーク削除
    work.destroy!

    # ワーク削除成功したらS3の画像を削除
    begin
      S3ImageUtil.delete_image_by_url(work.screenshot_url)
    rescue S3DeleteError => e
      Rails.logger.warn("S3 delete failed: #{e.message}")
    end

    render json: { status: "success" }, status: :created

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
    # パラメータがない場合はこのパスに入らず
    # 404エラー返すようroute.rbに記載済みのためバリデーションなし

    # ワーク取得
    works = Work.where(user_id: user_id)
    render json: { status: "success", works: works }, status: :ok
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
