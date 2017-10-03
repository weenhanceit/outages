Rails.application.routes.draw do
  devise_for :users, controllers: {
    invitations: :invitations,
    registrations: :registrations
  }
  # The following should be where Devise goes after login.
  get "user_root", to: "outages#index"

  root "welcome#index"

  # get "/outages", to: "outages#index", as: "outages_index"
  resources :accounts do
    namespace :admin do
      resources :users,
        shallow: true,
        only: [:destroy, :edit, :index, :update] do
          member do
            post "resend_invitation"
          end
        end
    end
  end
  resources :cis do
    resources :notes, shallow: true, only: [:create, :destroy, :edit, :update]
  end
  resources :outages do
    collection do
      get "day"
      get "fourday"
      get "month"
      get "week"
    end
    resources :notes, shallow: true, only: [:create, :destroy, :edit, :update]
  end
  resources :notifications, only: [:update]
  resources :searches, only: [:index]
  resource :user, only: [:edit, :update]
  resources :watches, only: [:create, :edit, :update]
  [
    "contact_us",
    "introduction",
    "outages",
    "preferences",
    "services",
    "set_up_account",
    "watches"
  ].each do |page|
    get "documentation/#{page}",
      to: "documentation##{page}",
      as: "documentation_#{page}".to_sym
  end
  # get "documentation/set_up_account",
  #   to: "documentation#set_up_account",
  #   as: :set_up_account
  get "features", to: "welcome#features", as: :features
  get "pricing", to: "welcome#pricing", as: :pricing
  get "welcome", to: "welcome#index", as: :welcome
end
