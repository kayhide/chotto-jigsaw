Rails.application.routes.draw do
  root to: "public#index"

  resources :users
  resources :puzzles, only: [:index, :show, :new, :create, :destroy], shallow: true do
    resources :games, only: [:index, :show, :create, :destroy]
  end

  resource :login, only: [:show, :create, :destroy]
end
