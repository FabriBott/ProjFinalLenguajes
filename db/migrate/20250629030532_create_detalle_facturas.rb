class CreateDetalleFacturas < ActiveRecord::Migration[8.0]
  def change
    create_table :detalle_facturas do |t|
      t.references :factura, null: false, foreign_key: true
      t.references :producto, null: false, foreign_key: true
      t.integer :cantidad
      t.decimal :precio_unitario
      t.decimal :subtotal

      t.timestamps
    end
  end
end
