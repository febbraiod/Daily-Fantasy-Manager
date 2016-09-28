class AddOppToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :opponent_id, :integer
  end
end
