class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]

  # GET /routes
  # GET /routes.json
  def index
    @routes = Route.all
  end

  def find_route_distance
    last_station = nil
    distance = 0

    params["stations"].each do |station_id|
      next_station = Station.find(station_id.to_i)

      if last_station
        if last_station.destinations.include? next_station
          distance += last_station.origins.select { |e| e.destination_id == station_id.to_i }.first.distance
        else
          render status: :not_found, body: { error: 'No Such Route' }.to_json
          return
        end
      end

      # assign the last_station
      last_station = next_station
    end

    render status: 200, body: { distance: distance }.to_json
  end

  def find_shortest_route
    
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
