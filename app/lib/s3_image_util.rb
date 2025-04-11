require "aws-sdk-s3"

class S3UploadError < StandardError; end
class S3DeleteError < StandardError; end

class S3ImageUtil
  def self.generate_s3_key(title, extension)
    missing_keys=[]
    missing_keys << "title" if title.blank?
    missing_keys << "extension" if extension.blank?
    if missing_keys.any?
      raise ArgumentError, "Missing required parameters: #{missing_keys.join(', ')}"
    end

    safe_title = title.to_s.parameterize
    formatted_timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    "uploads/#{safe_title}_#{formatted_timestamp}.#{extension}"
  end

  def self.upload_image_to_s3(body:, key:, content_type:)
    # パラメータバリデーション
    missing_keys=[]
    missing_keys << "body" if body.blank?
    missing_keys << "key" if key.blank?
    missing_keys << "content_type" if content_type.blank?
    if missing_keys.any?
      raise ArgumentError, "Missing required parameters: #{missing_keys.join(', ')}"
    end
    # S3に画像アップロード
    s3_client.put_object(bucket: ENV["S3_BUCKET_NAME"], key: key, body: body, content_type: content_type)
    # CloudFrontのURL返却
    "#{ENV["CLOUDFRONT_URL"]}/#{key}"
  rescue Aws::S3::Errors::ServiceError => e
    raise S3UploadError, "S3 upload failed: #{e.message}"
  end

  def self.delete_image_by_url(url)
    # パラメータバリデーション
    missing_keys=[]
    missing_keys << "url" if url.blank?
    if missing_keys.any?
      raise ArgumentError, "Missing required parameters: #{missing_keys.join(', ')}"
    end
    # S3から画像削除
    key = URI.parse(url).path[1..]
    s3_client.delete_object(bucket: ENV["S3_BUCKET_NAME"], key: key)
  rescue Aws::S3::Errors::ServiceError => e
    raise S3DeleteError, "S3 delete failed: #{e.message}"
  end

  def self.s3_client
    Aws::S3::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )
  end
end
