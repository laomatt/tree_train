require 'test_helper'

class StationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Station.create({name: 'A'})
    Station.create({name: 'B'})
    Station.create({name: 'C'})
    Station.create({name: 'D'})
    Station.create({name: 'E'})

    @station_a = Station.find_by_name('A')
    @station_b = Station.find_by_name('B')
    @station_c = Station.find_by_name('C')
    @station_d = Station.find_by_name('D')
    @station_e = Station.find_by_name('E')

    Route.create({origin: @station_a, destination: @station_b, distance: 5})
    Route.create({origin: @station_b, destination: @station_c, distance: 4})
    Route.create({origin: @station_c, destination: @station_d, distance: 8})
    Route.create({origin: @station_d, destination: @station_c, distance: 8})
    Route.create({origin: @station_d, destination: @station_e, distance: 6})
    Route.create({origin: @station_a, destination: @station_d, distance: 5})
    Route.create({origin: @station_c, destination: @station_e, distance: 2})
    Route.create({origin: @station_e, destination: @station_b, distance: 3})
    Route.create({origin: @station_a, destination: @station_e, distance: 7})
  end

  test 'find round trips' do 
    test_cases = [
      { origin: 'C', destination: 'C', maximum: 3, type: 'max_stops', answer: 2, status: 200 },
      { origin: 'A', destination: 'C', maximum: 4, type: 'exact_stops', answer: 3, status: 200 },
      { origin: 'C', destination: 'C', maximum: 30, type: 'max_dist', answer: 7, status: 200 },
      { origin: '', destination: 'C', maximum: 30, type: 'max_dist', error: 'Origin not found', status: 404 },
      { origin: nil, destination: 'C', maximum: 30, type: 'max_dist', error: 'Origin not found', status: 404 },
      { origin: 'C', destination: '', maximum: 30, type: 'max_dist', error: 'Destination not found', status: 404 },
      { origin: 'C', destination: nil, maximum: 30, type: 'max_dist', error: 'Destination not found', status: 404 },
      { origin: 'C', destination: 'C', maximum: '', type: 'max_dist', error: 'You are missing the maximum parameter', status: 422 },
      { origin: 'C', destination: 'C', maximum: nil, type: 'max_dist', error: 'You are missing the maximum parameter', status: 422 },
      { origin: 'C', destination: 'C', maximum: 2, type: 'max_runs', error: 'That is not a valid query type', status: 422 },
      { origin: 'X', destination: 'C', maximum: 4, type: 'max_dist', error: 'Origin not found', status: 404 },
      { origin: 'C', destination: 'X', maximum: 5, type: 'max_dist', error: 'Destination not found', status: 404 }
    ]

    test_cases.each do |t|
      get find_trips_with_stops_stations_url, params: t.slice(:origin, :destination, :maximum, :type)
      assert_response t[:status]
      if t[:status] == 200
        assert_equal(t[:answer], JSON.parse(response.body)["answer"].to_i, "number of trips for #{t[:origin]} to #{t[:destination]} is wrong")
      else
        assert_equal(t[:error], JSON.parse(response.body)["error"], "number of trips for #{t[:origin]} to #{t[:destination]} is wrong")
      end
    end
  end

end
