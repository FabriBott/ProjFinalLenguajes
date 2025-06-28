class CreateProductos < ActiveRecord::Migration[8.0]
  def change
    create_table :productos do |t|
      t.string :nombre
      t.decimal :precio

      t.timestamps
    end
  end
end
