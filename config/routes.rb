Rails.application.routes.draw do
  devise_for :users, path: "secure"
  
  get "home", to: "pages#home"
  get "about", to: "pages#about"

  namespace :api do
    namespace :v1 do
      post "auth", to: "auth#create"
      resources :entries
    end
  end

  

  resources :entries
  root "entries#index"
end
