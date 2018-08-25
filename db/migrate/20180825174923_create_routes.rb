class CreateRoutes < ActiveRecord::Migration[5.2]
  def change
    create_table :routes do |t|
      t.integer :origin_id
      t.integer :destination_id
      t.integer :distance

      t.timestamps
    end
  end
end
