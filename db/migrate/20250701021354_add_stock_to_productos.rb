class AddStockToProductos < ActiveRecord::Migration[8.0]
  def change
    add_column :productos, :stock, :integer, default: 0, null: false
    add_index :productos, :stock
  end
end
