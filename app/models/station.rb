class Station < ApplicationRecord
	has_many :origins, class_name: 'Route', foreign_key: :origin_id
	has_many :destinations, through: :origins
	validates_uniqueness_of :name

	def end_points
		origins.includes(:destination)
	end
end
