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
      { origin: 'C', destination: 'C', max: 3, answer: 2, status: 200 }
    ]

    test_cases.each do |t|
      get find_trips_with_max_stops_stations_url, params: {
          origin: t[:origin], 
          destination: t[:destination], 
          max_stops: t[:max] 
        }

      assert_response t[:status]
      assert_equal(t[:answer], JSON.parse(response.body)["num_trips"].to_i, "number of trips for #{t[:origin]} to #{t[:destination]} is wrong")

    end
  end


  # test "should get index" do
  #   get stations_url
  #   assert_response :success
  # end

  # test "should get new" do
  #   get new_station_url
  #   assert_response :success
  # end

  # test "should create station" do
  #   assert_difference('Station.count') do
  #     post stations_url, params: { station: { name: @station.name } }
  #   end

  #   assert_redirected_to station_url(Station.last)
  # end

  # test "should show station" do
  #   get station_url(@station)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_station_url(@station)
  #   assert_response :success
  # end

  # test "should update station" do
  #   patch station_url(@station), params: { station: { name: @station.name } }
  #   assert_redirected_to station_url(@station)
  # end

  # test "should destroy station" do
  #   assert_difference('Station.count', -1) do
  #     delete station_url(@station)
  #   end

  #   assert_redirected_to stations_url
  # end
end
