namespace :db do
  desc "This task sets up our test env"
	task :setup_test_env => :environment do 
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
end