Rails.application.routes.draw do
  root to: "users#index"

  resources :users
  resources :puzzles

  resource :login, only: [:show, :create, :destroy]
end
