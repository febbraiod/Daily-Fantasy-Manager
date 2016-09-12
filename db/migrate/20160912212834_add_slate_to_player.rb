class AddSlateToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :slate, :integer
    add_column :players, :custom_proj, :float
  end
end
