class Route < ApplicationRecord
	belongs_to :destination, class_name: 'Station'
	belongs_to :origin, class_name: 'Station'


	# this should make sure that no route is entered in twice
	validates_uniqueness_of :origin_id, :scope => :destination_id
end
