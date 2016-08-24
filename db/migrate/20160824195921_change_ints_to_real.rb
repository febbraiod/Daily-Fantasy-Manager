class ChangeIntsToReal < ActiveRecord::Migration
  def change
    change_column :players, :averageppg, :real
    change_column :players, :projected_points, :real, default: [], array: true
  end
end
