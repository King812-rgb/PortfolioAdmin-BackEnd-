module RequiredParams
  module Work
    def self.for(action)
      case action.to_sym
      when :create
        %i[user_id title description tech_stack screenshot_image_base64 site_url github_url released_on is_published]
      when :update
        %i[id user_id title description tech_stack screenshot_image_base64 site_url github_url released_on is_published]
      when :destroy
        %i[id user_id]
      else
        []
      end
    end
  end
end
