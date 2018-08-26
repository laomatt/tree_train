# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


Station.create({name: 'A'})
Station.create({name: 'B'})
Station.create({name: 'C'})
Station.create({name: 'D'})
Station.create({name: 'E'})

a = Station.find_by_name('A')
b = Station.find_by_name('B')
c = Station.find_by_name('C')
d = Station.find_by_name('D')
e = Station.find_by_name('E')

Route.create({origin: a, destination: b, distance: 5})
Route.create({origin: b, destination: c, distance: 4})
Route.create({origin: c, destination: d, distance: 8})
Route.create({origin: d, destination: c, distance: 8})
Route.create({origin: d, destination: e, distance: 6})
Route.create({origin: a, destination: d, distance: 5})
Route.create({origin: c, destination: e, distance: 2})
Route.create({origin: e, destination: b, distance: 3})
Route.create({origin: a, destination: e, distance: 7})


