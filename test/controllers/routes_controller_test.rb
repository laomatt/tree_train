require 'test_helper'
require 'byebug'

class RoutesControllerTest < ActionDispatch::IntegrationTest
  
  
  setup do
  end

  test "should get the distance of a given route" do 

    cases = [
        { route: ['A','B','C'], answer: 9, status: 200 },
        { route: ['A','D'], answer: 5, status: 200 },
        { route: ['A','D','C'], answer: 13, status: 200 },
        { route: ['A','E','B','C','D'], answer: 22, status: 200 },
        { route: ['A','E','D'], error: 'No Such Route', status: 404 },
        { route: ['A',nil,'D'], error: 'No Such Route', status: 404 },
        { route: [nil,'E','D'], error: 'No Such Route', status: 404 },
        { route: [nil,'E',nil], error: 'No Such Route', status: 404 },
        { route: [nil,nil,nil], error: 'No Such Route', status: 404 },
        { route: ['A','E','X'], error: 'No Such Route', status: 404 },
        { route: [], error: 'A Route is Required', status: 422 },
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
        assert_equal(test_case[:answer], JSON.parse(response.body)["answer"].to_i, "Distance of #{path} is wrong")
      else
        assert_equal(test_case[:error], JSON.parse(response.body)["error"], "error message is wrong")
      end
    end
  end

  test "find shortest route" do 
    cases = [
      # {origin: 'A', destination: 'C', answer: 9, status: 200},
      # {origin: 'B', destination: 'B', answer: 9, status: 200}
    ]

    # TODO: check of no route exists

    cases.each do |test_case|
      get find_shortest_route_routes_url, params: test_case.slice(:origin, :destination)

      assert_response test_case[:status]

      assert_equal(test_case[:answer], JSON.parse(response.body)['answer'].to_i, "distace wrong for #{test_case[:origin]} to #{test_case[:destination]}")
    end
  end

end
