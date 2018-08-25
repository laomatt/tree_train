Rails.application.routes.draw do
  resources :routes
  resources :stations
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "stations#index" 
end
