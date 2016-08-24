class AddColumnsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :averageppg, :integer
    add_column :players, :team, :string
    add_column :players, :opponent, :string
    add_column :players, :injury_status, :string
  end
end
