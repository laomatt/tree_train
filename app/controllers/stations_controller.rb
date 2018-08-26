class StationsController < ApplicationController
  before_action :set_station, only: [:show, :edit, :update, :destroy]

  # GET /stations
  # GET /stations.json
  def index
    @stations = Station.includes(origins: :destination).all
  end

  def parse_string_into_stations_and_routes
    
  end

  def find_trips_with_stops
    trips = 0
    destination = Station.find_by_name(params[:destination])
    max = params[:stops].to_i
    max_dist = params[:max_dist].to_i

    type_of_query = params[:type]

    traverse = ->(station,dist,visited) do 

      case type_of_query
      when 'max_dist'
        return if dist >= max_dist
      when 'max_stops'
        return if visited.length > max 
      when 'exact_stops'
        return if visited.length > max 
      end

      if station == destination
        case type_of_query
        when 'max_stops'
          if visited.length > 0
            trips += 1
            return
          end
        when 'exact_stops'
          if visited.length == max
            trips += 1
            return
          end
        when 'max_dist'
          if dist < max_dist && dist > 0
            visited_cl = visited.clone
            visited_cl << station
            trips += 1
            # no return statment here, since circular paths are allowed
          end
        end
      end

      visited << station

      if type_of_query == 'max_dist'
        # p station.origins.includes(:destination).map { |e| e.destination }
        station.origins.includes(:destination).each do |dest|
          traverse.call(
            dest.destination,
            dist.clone+dest.distance,
            visited.clone
          ) #if !visited.include? dest.destination
        end
      else
        station.destinations.each do |dest|
          traverse.call(
            dest,
            nil,
            visited.clone
          )
        end
      end
    end

    # find the origin
    origin = Station.find_by_name(params[:origin])
    traverse.call(origin, 0, [])

    render status: 200, body: { num_trips: trips }.to_json
  end

  # GET /stations/1
  # GET /stations/1.json
  def show
  end

  # GET /stations/new
  def new
    @station = Station.new
  end

  # GET /stations/1/edit
  def edit
  end

  # POST /stations
  # POST /stations.json
  def create
    @station = Station.new(station_params)

    respond_to do |format|
      if @station.save
        format.html { redirect_to @station, notice: 'Station was successfully created.' }
        format.json { render :show, status: :created, location: @station }
      else
        format.html { render :new }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stations/1
  # PATCH/PUT /stations/1.json
  def update
    respond_to do |format|
      if @station.update(station_params)
        format.html { redirect_to @station, notice: 'Station was successfully updated.' }
        format.json { render :show, status: :ok, location: @station }
      else
        format.html { render :edit }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stations/1
  # DELETE /stations/1.json
  def destroy
    @station.destroy
    respond_to do |format|
      format.html { redirect_to stations_url, notice: 'Station was successfully destroyed.' }
      format.json { head :no_content }
    end
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
