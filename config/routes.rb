Rails.application.routes.draw do
  # Put this before Devise during the transition so the old tests still work.
  resources :users, only: [:create, :destroy]
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "outages#index"

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
  resources :preferences, only: [:edit]
  resources :searches, only: [:index]
end
