require 'test_helper'
require 'byebug'
class RoutesControllerTest < ActionDispatch::IntegrationTest
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

    @route_1 = Route.last
  end

  test "should get the distance of a given route" do 

    cases = {
        ['A','B','C'] => { answer: 9, status: 200 },
        ['A','D'] => { answer: 5, status: 200 },
        ['A','D','C'] => { answer: 13, status: 200 },
        ['A','E','B','C','D'] => { answer: 22, status: 200 },
        ['A','E','D'] => {error: 'No Such Route', status: 404 },
        'A-B-C' => { answer: 9, status: 200 },
        'A-D' => { answer: 5, status: 200 },
        'A-D-C' => { answer: 13, status: 200 },
        'A-E-B-C-D' => { answer: 22, status: 200 },
        'A-E-D' => {error: 'No Such Route', status: 404 }
    }

    cases.each do |path, answers|
      get find_route_distance_routes_url, params: { stations: path }

      assert_response answers[:status]

      if answers[:status] == 200
        assert_equal(answers[:answer], JSON.parse(response.body)["distance"].to_i, "Distance of #{path} is wrong")
      else
        assert_equal(answers[:error], JSON.parse(response.body)["error"], "error message is wrong")
      end
    end
  end

  test "find shortest route" do 
    cases = [
      {origin: 'A', destination: 'C', answer: 9, status: 200},
      {origin: 'B', destination: 'B', answer: 9, status: 200}
    ]

    cases.each do |test_case|
      get find_shortest_route_routes_url, params: test_case.slice(:origin, :destination)

      assert_response test_case[:status]

      assert_equal(test_case[:answer], JSON.parse(response.body)['distance'].to_i, "distace wrong for #{test_case[:origin]} to #{test_case[:destination]}")
    end
  end

end
