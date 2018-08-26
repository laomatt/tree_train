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
        ['A','E','D'] => {error: 'No Such Route', status: 404 }
    }

    cases.each do |path, answers|
      get find_route_distance_routes_url, params: { stations: path.map { |e| Station.find_by_name(e).id }}

      assert_response answers[:status]

      if answers[:status] == 200
        assert_equal(answers[:answer], JSON.parse(response.body)["distance"].to_i, "Distance of #{path} is wrong")
      else
        assert_equal(answers[:error], JSON.parse(response.body)["error"], "error message is wrong")
      end
    end
  end

  test "should give a 404 error if the route doesn't exist" do 
    get find_route_distance_routes_url, params: { stations: [@station_b.id, @station_d.id, @station_b.id]}
    assert_response :not_found
    assert_equal("No Such Route", JSON.parse(response.body)["error"], "error message is wrong")

  end

  test "find shortest route" do 
    cases = [
      {origin: 'A', destination: 'C', answer: 9, status: 200},
      {origin: 'B', destination: 'B', answer: 9, status: 200}
    ]

    cases.each do |test_case|
      get find_shortest_route_routes_url, params: test_case.slice(:origin, :destination)

      assert_response test_case[:status]
      assert_equal(test_case[:answer], JSON.parse(response.body)['distance'], "distace wrong for #{test_case[:origin]} to #{test_case[:destination]}")
    end
  end



  # test "should get index" do
  #   get routes_url
  #   assert_response :success
  # end

  # test "should get new" do
  #   get new_route_url
  #   assert_response :success
  # end

  # test "should create route" do
  #   assert_difference('Route.count') do
  #     post routes_url, params: { route: { destination_id: @route_1.destination_id, distance: @route_1.distance, origin_id: @route_1.origin_id } }
  #   end

  #   assert_redirected_to route_url(Route.last)
  # end

  # test "should show route" do
  #   get route_url(@route)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_route_url(@route)
  #   assert_response :success
  # end

  # test "should update route" do
  #   patch route_url(@route), params: { route: { destination_id: @route.destination_id, distance: @route.distance, origin_id: @route.origin_id } }
  #   assert_redirected_to route_url(@route)
  # end

  # test "should destroy route" do
  #   assert_difference('Route.count', -1) do
  #     delete route_url(@route)
  #   end

  #   assert_redirected_to routes_url
  # end
end
