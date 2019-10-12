Rails.application.routes.draw do
  root to: "puzzles#index"

  resources :users
  resources :puzzles, only: [:index, :show, :new, :create, :destroy]

  resource :login, only: [:show, :create, :destroy]
end
