require 'set'
class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]
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
    origin = Station.find_by_name(params[:origin])
    destination = Station.find_by_name(params[:destination])
    distances = []
    paths = []
    
    traverse = ->(station, travel_distance, visited) do 
      visited << station

      station.origins.includes(:destination).each do |st|
        new_travel_distance = travel_distance.clone
        new_travel_distance += st.distance.to_i

        if st.destination == destination
          visited << st.destination
          paths << visited
          distances << new_travel_distance if new_travel_distance > 0
          return
        end

        # we should not visit already visited stations
        traverse.call(st.destination, new_travel_distance, visited.clone) if !visited.include? st.destination
      end
    end

    # we should return a 404 if there exists no current round trips
    if origin.nil?
      render status: 404, body: { error: "Origin not found" }.to_json
      return
    end

    # we should return a 404 if there exists no current round trips
    if destination.nil?
      render status: 404, body: { error: "Destination not found" }.to_json
      return
    end


    if origin == destination
      # if it is a round trip we want to skip past the first stop
      origin.origins.includes(:destination).each do |d|
        traverse.call(d.destination, d.distance, [origin])
      end
    else
      traverse.call(origin, 0, [])
    end

    # we should return a 404 if there exists no current round trips
    if distances.empty?
      render status: 404, body: { error: "there are no trips from #{origin.name} to #{destination.name}" }.to_json
      return
    end

    answer = paths.min_by(&:length)

    render status: 200, body: { answer: distances.min , route: [parse_routes(answer)] }.to_json
  end

  def djystras_algo_for_shortest_path
    memo = {}
    origin = Station.find_by_name(params[:origin])
    destination = Station.find_by_name(params[:destination])
    visited = Set.new
    # vertex => {prev_vert: node, dist_from_org: int}
    # start with origin, find its path from itself
    memo[origin] = {prev_vert: nil, dist_from_org: 0}
    # examine all of its unvisited neighbors (origins), and record all of its neighbors path sum from orgin to it (so dist_from_org from the previous node)
    traverse = ->(node) do 
      dist_from_o = memo[node][:dist_from_org]
      # add the previus node to the visited set
      visited.add node
      node.origins.includes(:destination).each do |org|
        d = org.destination
        # if any of these sums is less than thier recorded sums, then we replace the value with the sum
        summed = org.distance + dist_from_o
        if memo[d]
          if summed < memo[d][:dist_from_org]
            memo[d][:dist_from_org] = org.distance + dist_from_o 
            # change the previous node in each of the neighbors to the last node (origin in this case)
            memo[d][:prev_vert] = node
          end
        else
          memo[d] = { prev_vert: node, dist_from_org: summed }
        end
        
        traverse.call(d) if !visited.include?(d)
      end
    end

    traverse.call(origin)

    if memo[destination].nil?
      render status: 404, body: { error: "there are no trips from #{origin.name} to #{destination.name}" }.to_json
      return
    end

    answer = memo[destination][:dist_from_org]
    render status: 200, body: { answer: answer }.to_json
  end

  # GET /routes/1
  # GET /routes/1.json
  def show
  end

  # GET /routes/new
  def new
    @route = Route.new
  end

  # GET /routes/1/edit
  def edit
  end

  # POST /routes
  # POST /routes.json
  def create
    @route = Route.new(route_params)

    respond_to do |format|
      if @route.save
        format.html { redirect_to @route, notice: 'Route was successfully created.' }
        format.json { render :show, status: :created, location: @route }
      else
        format.html { render :new }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /routes/1
  # PATCH/PUT /routes/1.json
  def update
    respond_to do |format|
      if @route.update(route_params)
        format.html { redirect_to @route, notice: 'Route was successfully updated.' }
        format.json { render :show, status: :ok, location: @route }
      else
        format.html { render :edit }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /routes/1
  # DELETE /routes/1.json
  def destroy
    @route.destroy
    respond_to do |format|
      format.html { redirect_to routes_url, notice: 'Route was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @route = Route.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def route_params
      params.require(:route).permit(:origin_id, :destination_id, :distance)
    end
end
