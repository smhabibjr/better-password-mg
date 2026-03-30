Rails.application.routes.draw do
  get "products/index"
  get "products/show"
  resources :entries
  devise_for :users, path: "secure"
  get "home", to: "pages#home"
  get "about", to: "pages#about"

  resources :products, only: [:index, :show]
  resources :sellers, only: [:index, :show]
  
  root "entries#index"
end
