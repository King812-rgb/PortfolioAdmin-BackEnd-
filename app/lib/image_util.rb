require "base64"

class ImageDecodeError < StandardError; end

module ImageUtil
  def self.decode_base64_image(base64_str)
    encoded = base64_str.split(",")[1]
    raise ImageDecodeError, "Invalid base64 image: #{base64_str}" if encoded.nil?
    extension = base64_str[/data:image\/(.*);base64/, 1] || "png"
    content_type = "image/#{extension}"
    body = Base64.decode64(encoded)

    { body: body, extension: extension, content_type: content_type }
  rescue => e
    raise ImageDecodeError, "Invalid base64 image: #{e.message}"
  end
end
