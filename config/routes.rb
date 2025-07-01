Rails.application.routes.draw do
  resources :tasa_impuestos
  resources :clientes do
    member do
      patch :toggle_estado
    end
  end
  resources :facturas, only: [:index, :show, :new, :create] do
    member do
      get :pdf
    end
  end
  resources :productos
  
  root "facturas#index"
end
