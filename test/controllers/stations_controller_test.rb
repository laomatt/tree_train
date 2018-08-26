require 'test_helper'

class StationsControllerTest < ActionDispatch::IntegrationTest

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
      { origin: 'C', destination: 'X', maximum: 5, type: 'max_dist', error: 'Destination not found', status: 404 },
      { origin: 'C', destination: 'C', maximum: 30, type: 'max_stops', answer: 6529, status: 200 }, # TODO: optimize
      { origin: 'C', destination: 'C', maximum: 80, type: 'max_dist', answer: 403, status: 200 } # TODO: optimize
    ]

    test_cases.each do |t|
      get find_trips_with_stops_stations_url, params: t.slice(:origin, :destination, :maximum, :type)
      assert_response t[:status]
      if t[:status] == 200
        assert_equal(t[:answer], JSON.parse(response.body)["answer"].to_i, "number of trips for #{t[:origin]} to #{t[:destination]} is wrong for #{t[:type]}: #{t[:maximum]}")
      else
        assert_equal(t[:error], JSON.parse(response.body)["error"], "number of trips for #{t[:origin]} to #{t[:destination]} is wrong for #{t[:type]}")
      end
    end
  end

end
