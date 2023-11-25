Rails.application.routes.draw do
  # mount_devise_token_auth_for 'User', at: 'auth'
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
  namespace :api, fomat: :json do
    scope :v1 do
      mount_devise_token_auth_for 'User', at: 'auth',skip: [:omniauth_callbacks], controllers: {
        registrations: "devise_token_auth/registrations",
        sessions: "devise_token_auth/sessions"
      }
    end
  end
  root "top#index"
  namespace :admin do
    resources :books, only: [:index, :new, :create] do
      collection do
        get "search"
        post "search_registration"
      end
    end
    resources :users, only: [:index]
    resources :requests, only: [:index] do
      member { post 'toggle'}
    end
  end

  resources :books
  resources :reservations, only: [:index, :show, :create, :destroy]
  resources :lendings, only: [:index, :show, :create, :update]
  resources :request_books, only: [:index, :create, :update] do
    collection {get "search"}
  end
  get "/searches", action: "index", controller: "searches"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
