Rails.application.routes.draw do
  resources :routes do 
  	collection do 
	  	get 'find_route_distance'
	  	get 'find_shortest_route'
      get 'djystras_algo_for_shortest_path'
  	end
  end
  
  resources :stations do 
    collection do 
      get 'find_trips_with_stops'
      post 'parse_string_into_stations_and_routes'
    end
  end

  root "stations#index" 
end
