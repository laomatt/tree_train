module RoutesHelper
	def parse_routes(arr)
		arr.map(&:name).join(' -> ')
	end
end
