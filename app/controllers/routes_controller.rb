require 'set'
class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]
  before_action :find_origin_and_destination, only: [:find_shortest_route, :djystras_algo_for_shortest_path, :iterative_find_shortest_distance]
  include RoutesHelper
  # GET /routes
  # GET /routes.json
  def index
    @routes = Route.all
  end

  def find_route_distance
    last_station = nil
    distance = 0

    if params['stations'].is_a? String
      stations = params["stations"].split('-')
    else
      stations = params["stations"]
    end

    if stations.nil? || stations.empty?
      render status: 422, body: { error: 'A Route is Required' }.to_json
      return
    end

    stations.each do |station_name|
      next_station = Station.find_by_name(station_name)

      if next_station.nil?
        render status: :not_found, body: { error: 'No Such Route' }.to_json
        return
      end

      if last_station
        if last_station.destinations.include? next_station
          distance += last_station.origins.includes(:destination).select { |e| e.destination.name == station_name }.first.distance
        else
          render status: :not_found, body: { error: 'No Such Route' }.to_json
          return
        end
      end

      # assign the last_station
      last_station = next_station
    end

    render status: 200, body: { answer: distance }.to_json
  end

  def find_shortest_route
    last_station = nil
    distance = 0
    distances = []
    paths = []
    
    traverse = ->(station, travel_distance, visited) do 
      visited << station

      station.origins.includes(:destination).each do |st|
        new_travel_distance = travel_distance.clone
        new_travel_distance += st.distance.to_i

        if st.destination == @destination
          visited << st.destination
          paths << visited
          distances << new_travel_distance if new_travel_distance > 0
          return
        end

        # we should not visit already visited stations
        traverse.call(st.destination, new_travel_distance, visited.clone) if !visited.include? st.destination
      end
    end

    if @origin == @destination
      # if it is a round trip we want to skip past the first stop
      @origin.origins.includes(:destination).each do |d|
        traverse.call(d.destination, d.distance, [@origin])
      end
    else
      traverse.call(@origin, 0, [])
    end

    # we should return a 404 if there exists no current round trips
    if distances.empty?
      render status: 404, body: { error: "there are no trips from #{@origin.name} to #{@destination.name}" }.to_json
      return
    end

    answer = paths.min_by(&:length)

    render status: 200, body: { answer: distances.min , route: [parse_routes(answer)] }.to_json
  end

  def djystras_algo_for_shortest_path
    # this is a better algorithm than the one I am using for getting the min distance, since it is a greedy algorithm and hence does not need to look at ALL the possible paths, but just calculates as it goes along, but this does not work for cases in which the origin is the same as the destination

    memo = {}
    visited = Set.new
    

    # vertex => {previous_node: node, distance_from_origin: int}
    # start with origin, find its path from itself
    memo[@origin] = {previous_node: nil, distance_from_origin: 0}
    # examine all of its unvisited neighbors (origins), and record all of its neighbors path sum from orgin to it (so distance_from_origin from the previous node)
    traverse = ->(node) do 
      dist_from_o = memo[node][:distance_from_origin]
      # add the previous node to the visited set
      visited.add node
      sma = nil
      node.origins.includes(:destination).each do |org|
        d = org.destination
        # if any of these sums is less than thier recorded sums, then we replace the value with the sum
        summed = org.distance + dist_from_o
        if memo[d]
          if summed < memo[d][:distance_from_origin]
            memo[d][:distance_from_origin] = summed
            # change the previous node in each of the neighbors to the last node (origin in this case)
            memo[d][:previous_node] = node
          end
        else
          memo[d] = { previous_node: node, distance_from_origin: summed }
        end

        
      end

      # call traverse on the smallest distance from origin currently
      sma = memo.reject {|k,v| visited.include?(k) }.sort_by{|k,v| v[:distance_from_origin]}.first
      return if sma.nil?
      traverse.call(sma[0]) 
    end

    traverse.call(@origin)

    if memo[@destination].nil?
      render status: 404, body: { error: "there are no trips from #{params[:origin]} to #{params[:destination]}" }.to_json
      return
    end

    # to get the routes we need to work backwards via the 'prev_node' colomn
    current = @destination
    path = [@origin]

    answer = memo[@destination][:distance_from_origin]
    # routes not quite working
    render status: 200, body: { answer: answer }.to_json
  end

  def iterative_find_shortest_distance
    # iterativily parse. the graph
    current = @origin
    paths = []
    visited = Set.new

    current.origin.includes(:destination).each do |org|
      next if visited.include? org.destination
      
      # current = org.destination
      # while current != destination

      # end
    end

    render status: 200, body: { answer: 0 }.to_json
  end

  private

    def find_origin_and_destination
      @origin = Station.find_by_name(params[:origin])
      @destination = Station.find_by_name(params[:destination])

      # we should return a 404 if there exists no current round trips
      if @origin.nil?
        render status: 404, body: { error: "Origin not found" }.to_json
        return
      end

      # we should return a 404 if there exists no current round trips
      if @destination.nil?
        render status: 404, body: { error: "Destination not found" }.to_json
        return
      end

    end
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @route = Route.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def route_params
      params.require(:route).permit(:origin_id, :destination_id, :distance)
    end
end
