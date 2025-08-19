Rails.application.routes.draw do
  devise_for :users, path: "secure"
  get "/home", to: "pages#home"
  get "/about", to: "pages#about"
  # Defines the root path route ("/")
  root "pages#home"

  resources :entries
end
