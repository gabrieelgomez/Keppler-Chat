KepplerChat::Engine.routes.draw do
  namespace :admin do
    scope :chat, as: :chat do
      resources :messages do
      end

      namespace :conversations do
        post '/', action: :create_chat, as: :create_chat
      end

      resources :conversations do
        member do
          post :close
        end
        resources :messages, only: [:create]
      end

    end
  end
end
