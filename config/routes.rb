Rails.application.routes.draw do
  resources :productos
  root "productos#index"
end
