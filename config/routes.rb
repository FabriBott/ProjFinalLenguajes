Rails.application.routes.draw do
  resources :clientes
  resources :facturas, only: [:index, :show, :new, :create] do
    member do
      get :pdf
    end
  end
  resources :productos
  
  root "facturas#index"
end
