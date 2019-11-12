Rails.application.routes.draw do
  root to: "public#index"

  namespace :public do
    resources :puzzles, only: [:index]
  end

  resources :users
  resources :puzzles, only: [:index, :show, :new, :create, :destroy], shallow: true do
    namespace :games do
      resource :standalone, only: [:show], controller: :standalone
    end
    resources :games, only: [:index, :show, :create, :destroy]
  end

  resource :login, only: [:show, :create, :destroy]
end
