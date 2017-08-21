Rails.application.routes.draw do
  # Put this before Devise during the transition so the old tests still work.
  devise_for :users, controllers: { registrations: :registrations }
  # The following should be where Devise goes after login.
  get "user_root", to: "outages#index"

  root "welcome#index"

  # get "/outages", to: "outages#index", as: "outages_index"
  resources :accounts
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
  resources :welcome, only: [:index]
end
