class AddOwnershipToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :ownership, :integer
  end
end
