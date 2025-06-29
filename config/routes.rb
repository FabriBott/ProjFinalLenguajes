Rails.application.routes.draw do
  resources :clientes
  resources :facturas do
    member do
      get :pdf
    end
  end
  resources :productos
  
  root "facturas#index"
end
