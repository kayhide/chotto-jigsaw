Rails.application.routes.draw do
  resources :puzzles
  root to: "users#index"
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
