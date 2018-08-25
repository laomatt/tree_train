json.extract! route, :id, :origin_id, :destination_id, :distance, :created_at, :updated_at
json.url route_url(route, format: :json)
