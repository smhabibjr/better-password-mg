Rails.application.routes.draw do
  devise_for :users
  get "home", to: "pages#home"
  get "about", to: "pages#about"
  root "pages#home"
end
