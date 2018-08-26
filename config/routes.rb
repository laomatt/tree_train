Rails.application.routes.draw do
  resources :routes do 
  	collection do 
	  	get 'find_route_distance'
	  	get 'find_shortest_route'
  	end
  end
  
  resources :stations do 
    collection do 
      get 'find_trips_with_max_stops'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "stations#index" 
end
