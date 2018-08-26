Rails.application.routes.draw do
  resources :routes do 
  	collection do 
	  	get 'find_route_distance'
	  	get 'find_shortest_route'
  	end
  end
  
  resources :stations do 
    collection do 
      get 'find_trips_with_stops'
    end
  end

  root "stations#index" 
end
