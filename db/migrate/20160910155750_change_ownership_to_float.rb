class ChangeOwnershipToFloat < ActiveRecord::Migration
  def change
    change_column :players, :ownership, :float
  end
end
