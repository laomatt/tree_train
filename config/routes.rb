Rails.application.routes.draw do
  resources :routes do 
  	collection do 
	  	get 'find_route_distance'
	  	get 'find_shortest_route'
  	end
  end
  
  resources :stations do 
  	get 'find_trips_with_max_distance'
  	get 'find_round_trips_with_max_distance'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "stations#index" 
end
