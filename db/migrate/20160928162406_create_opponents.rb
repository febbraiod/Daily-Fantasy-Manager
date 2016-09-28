class CreateOpponents < ActiveRecord::Migration
  def change
    create_table :opponents do |t|
      t.string :team
      t.integer :qb
      t.integer :wr
      t.integer :rb
      t.integer :te

      t.timestamps null: false
    end
  end
end
