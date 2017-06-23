Rails.application.routes.draw do
  # Put this before Devise during the transition so the old tests still work.
  devise_for :users
  # The following should be where Devise goes after login.
  get "user_root_path", to: "outages#index"

  root "welcome#index"

  # get "/outages", to: "outages#index", as: "outages_index"
  # resources :cis, only: [:index, :edit, :update, :destroy, :show, :new]
  resources :cis
  resources :outages do
    collection do
      get "day"
      get "fourday"
      get "month"
      get "week"
    end
  end
  resources :preferences, only: [:edit, :update]
  resources :searches, only: [:index]
  resources :watches, only: [:create, :edit, :update]
  resources :welcome, only: [:index]
end
