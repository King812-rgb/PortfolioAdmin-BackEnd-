module ParamValidation
  extend ActiveSupport::Concern

  included do
    private

    def validate_required_keys!(action, param_module:)
      required_keys = param_module.for(action)
      missing_keys = required_keys.select { |k| params[k].blank? }
      if missing_keys.any?
        render json: {
          status: "error",
          error: {
            code: "INVALID_PARAM",
            message: "Missing required parameters: #{missing_keys.join(', ')}"
          }
        }, status: :bad_request
        return false
      end
      true
    end
  end
end
