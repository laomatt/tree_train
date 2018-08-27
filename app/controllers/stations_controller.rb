require 'set'

class StationsController < ApplicationController
  before_action :set_station, only: [:show, :edit, :update, :destroy]
  include RoutesHelper
  # GET /stations
  # GET /stations.json
  def index
    @stations = Station.includes(origins: :destination).all
  end

  def parse_string_into_stations_and_routes
    str = params[:string]

    str.split(',').map { |e| e.strip }.each do |s|
      if Station.exists?(name: s[0])
        origin = Station.find_by_name(s[0])
      else
        origin = Station.create(name: s[0])
      end

      if Station.exists?(name: s[1])
        destination = Station.find_by_name(s[1])
      else
        destination = Station.create(name: s[1])
      end

      route = Route.where("origin_id = ? and destination_id = ?", origin.id, destination.id).first

      if route
        route.update_attributes(distance: s[2..-1].to_i)
      else
        route = Route.create(origin: origin, destination: destination, distance: s[2..-1].to_i)
      end

    end

    redirect_back fallback_location: root_url, notice: 'Input successfully parsed.'
  end

  def find_trips_with_stops
    trips = 0
    destination = Station.find_by_name(params[:destination])
    routes = []

    if destination.nil?
      render status: 404, body: { error: 'Destination not found' }.to_json
      return
    end

    # find the origin
    origin = Station.find_by_name(params[:origin])

    if origin.nil?
      render status: 404, body: { error: 'Origin not found' }.to_json
      return
    end

    if params[:maximum].blank?
      render status: 422, body: { error: 'You are missing the maximum parameter' }.to_json
      return
    end

    if !['max_dist','max_stops','exact_stops'].include? params[:type]
      render status: 422, body: { error: 'That is not a valid query type' }.to_json
      return
    end


    # TODO: memorize exact stops
    valid_paths_so_far = Set.new

    max = params[:maximum].to_i
    type_of_query = params[:type]

    # maybe we can load up all concerning rows from the DB in one data swoop

    traverse = ->(station,dist,visited) do
      case type_of_query
      when 'max_dist'
        return if dist >= max
      when 'max_stops'
        return if visited.length > max 
      when 'exact_stops'
        return if visited.length > max 
      end

      valid_paths_so_far.add visited

      if station == destination && visited.last != origin
        case type_of_query
        when 'max_stops'
          if visited.length > 0
            visited << station
            routes << visited
            trips += 1
            # no return statement here because we want to keep going until we over shoot the max
          end
        when 'exact_stops'
          if visited.length == max
            visited << station
            routes << visited
            trips += 1
            return
          end
        when 'max_dist'
          if dist < max && dist > 0
            visited_cl = visited.clone
            visited_cl << station
            routes << visited_cl
            trips += 1
            # no return statment here, since circular paths are allowed but limited to the max distance
          end
        end
      end

      visited << station

      if type_of_query == 'max_dist'
        station.origins.includes(:destination).each do |dest|
          traverse.call(
            dest.destination,
            dist.clone+dest.distance,
            visited.clone
          ) 
        end
      else
        station.destinations.each do |dest|
          traverse.call(
            dest,
            nil,
            visited.clone
          ) #if !valid_paths_so_far.include?(vis)
        end
      end
    end


    traverse.call(origin, 0, [])

    render status: 200, body: { answer: trips, route: routes.map { |e| parse_routes(e) } }.to_json
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_station
      @station = Station.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def station_params
      params.require(:station).permit(:name)
    end
end
