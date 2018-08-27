require 'test_helper'
require 'byebug'

class RoutesControllerTest < ActionDispatch::IntegrationTest

  test "should get the distance of a given route" do 

    cases = [
        { route: ['A','B','C'], answer: 9, status: 200 },
        { route: ['A','D'], answer: 5, status: 200 },
        { route: ['A','D','C'], answer: 13, status: 200 },
        { route: ['A','E','B','C','D'], answer: 22, status: 200 },
        { route: ['A','E','D'], error: 'No Such Route', status: 404 },
        { route: ['A','nil','D'], error: 'No Such Route', status: 404 },
        { route: ['nil','E','D'], error: 'No Such Route', status: 404 },
        { route: ['nil','E','nil'], error: 'No Such Route', status: 404 },
        { route: ['nil','nil','nil'], error: 'No Such Route', status: 404 },
        { route: ['A','E','X'], error: 'No Such Route', status: 404 },
        { route: [], error: 'No Such Route', status: 404 },
        { route: '', error: 'A Route is Required', status: 422 },
        { route: 'A-B-C', answer: 9, status: 200 },
        { route: 'A-D', answer: 5, status: 200 },
        { route: 'A-D-C', answer: 13, status: 200 },
        { route: 'A-E-B-C-D', answer: 22, status: 200 },
        { route: 'A-E-D', error: 'No Such Route', status: 404 }
    ]

    cases.each do |test_case|
      get find_route_distance_routes_url, params: { stations: test_case[:route] }
      assert_response test_case[:status], "problem was #{test_case[:route]}"

      if test_case[:status] == 200
        assert_equal(test_case[:answer], JSON.parse(response.body)["answer"].to_i, "Distance of #{path} is wrong: #{test_case[:route]}")
      else
        assert_equal(test_case[:error], JSON.parse(response.body)["error"], "error message is wrong: #{test_case[:route]}")
      end
    end
  end

  test "find shortest route" do 
    cases = [
      {origin: 'A', destination: 'C', answer: 9, status: 200},
      {origin: 'B', destination: 'B', answer: 9, status: 200},
      {origin: '', destination: 'B', error: 'Origin not found', status: 404},
      {origin: 'X', destination: 'B', error: 'Origin not found', status: 404},
      {origin: 'B', destination: '', error: 'Destination not found', status: 404},
      {origin: 'B', destination: 'X', error: 'Destination not found', status: 404},
      {origin: 'D', destination: 'A', error: 'there are no trips from D to A', status: 404}
    ]

    # TODO: check of no route exists

    cases.each do |test_case|
      get find_shortest_route_routes_url, params: test_case.slice(:origin, :destination)
      assert_response test_case[:status]

      if test_case[:status] == 200
        assert_equal(test_case[:answer], JSON.parse(response.body)['answer'].to_i, "distance wrong for #{test_case[:origin]} to #{test_case[:destination]}")

        get djystras_algo_for_shortest_path_routes_url, params: test_case.slice(:origin, :destination)
        assert_equal(test_case[:answer], JSON.parse(response.body)['answer'].to_i, "djykstra distance wrong for #{test_case[:origin]} to #{test_case[:destination]}")
      else
        assert_equal(test_case[:error], JSON.parse(response.body)['error'], "error wrong for #{test_case[:origin]} to #{test_case[:destination]}")
      end
    end
  end

  test "find shortest route via djystras algorithm" do

    # lets create a larger graph
    post parse_string_into_stations_and_routes_stations_url, params: { string: "GF3, RT8, FT3, PG4, KP4, PK7, FP9, PO20, OR5, RV5, VX10, XZ7, ZS12, SK3, KL10, SM2, MR9, RP8, PR40, PT8, TF4"}

    cases = [
      {origin: 'G', destination: 'Z', answer: 59, status: 200},
      {origin: 'F', destination: 'V', answer: 39, status: 200},
      {origin: 'F', destination: 'P', answer: 9, status: 200}
    ]

    cases.each do |test_case|
      get djystras_algo_for_shortest_path_routes_url, params: test_case.slice(:origin, :destination)
      assert_equal(test_case[:answer], JSON.parse(response.body)['answer'].to_i, "distace wrong for #{test_case[:origin]} to #{test_case[:destination]}")

      
      get find_shortest_route_routes_url, params: test_case.slice(:origin, :destination)
      assert_equal(test_case[:answer], JSON.parse(response.body)['answer'].to_i, "distace wrong for #{test_case[:origin]} to #{test_case[:destination]}")
    end
  end

end
