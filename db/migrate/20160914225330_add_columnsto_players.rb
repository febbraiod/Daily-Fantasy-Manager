class AddColumnstoPlayers < ActiveRecord::Migration
  def change
    add_column :players, :dropoff, :float
    add_column :players, :cap, :float
    add_column :players, :dropoff_5, :float
    add_column :players, :cap_5, :float
  end
end
