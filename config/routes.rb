Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "outages#index"

  # get "/outages", to: "outages#index", as: "outages_index"
  resources :cis, only: [:index, :edit, :update, :destroy, :show, :new]
  resources :outages, only: [:index, :edit, :show, :new]
  resources :preferences, only: [:edit]
  resources :searches, only: [:index]
  resources :users, only: [:create, :destroy]
end
