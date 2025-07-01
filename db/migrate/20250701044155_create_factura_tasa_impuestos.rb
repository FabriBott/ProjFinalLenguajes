class CreateFacturaTasaImpuestos < ActiveRecord::Migration[8.0]
  def change
    create_table :factura_tasa_impuestos do |t|
      t.references :factura, null: false, foreign_key: true
      t.references :tasa_impuesto, null: false, foreign_key: true
      t.decimal :monto_impuesto, precision: 10, scale: 2, default: 0
      t.timestamps
    end
    
    add_index :factura_tasa_impuestos, [:factura_id, :tasa_impuesto_id], unique: true, name: 'index_factura_tasa_impuestos_unique'
  end
end
