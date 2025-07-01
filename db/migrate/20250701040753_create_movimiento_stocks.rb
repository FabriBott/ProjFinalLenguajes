class CreateMovimientoStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :movimiento_stocks do |t|
      t.references :producto, null: false, foreign_key: true
      t.string :tipo_movimiento, null: false
      t.integer :cantidad, null: false
      t.integer :cantidad_anterior, null: false
      t.integer :cantidad_nueva, null: false
      t.string :motivo, null: false
      t.text :observaciones
      t.string :usuario, null: false
      t.datetime :fecha_movimiento, null: false

      t.timestamps
    end
    
    add_index :movimiento_stocks, :tipo_movimiento
    add_index :movimiento_stocks, :fecha_movimiento
    add_index :movimiento_stocks, [:producto_id, :fecha_movimiento]
  end
end
