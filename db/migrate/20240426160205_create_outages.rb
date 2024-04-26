class CreateOutages < ActiveRecord::Migration[7.1]
  def change
    create_table :outages do |t|
      t.string :eid
      t.float :device_lat
      t.float :device_lng
      t.integer :customers_affected
      t.string :cause
      t.string :jurisdiction
      t.json :convex_hull
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :requests, default: 0

      t.timestamps
    end
  end
end
