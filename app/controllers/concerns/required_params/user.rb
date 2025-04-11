module RequiredParams
  module User
    def self.for(action)
      case action.to_sym
      when :create
        %i[user_id name email]
      when :show
        %i[user_id]
      else
        []
      end
    end
  end
end
