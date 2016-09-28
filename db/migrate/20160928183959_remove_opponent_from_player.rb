class RemoveOpponentFromPlayer < ActiveRecord::Migration
  def change
    remove_column :players, :opponent
  end
end
