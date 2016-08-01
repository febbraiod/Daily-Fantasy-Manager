class AddProjectedPointsToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :projected_points, :integer, array: true, default: []
  end
end
