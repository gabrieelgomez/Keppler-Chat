module KepplerChat
  # Policy for Conversation model
  class ConversationPolicy < ControllerPolicy
    attr_reader :user, :objects

    def initialize(user, objects)
      @user = user
      @objects = objects
    end

    def create_chat?
      true
    end

    def close?
      true
    end

  end
end
