class CreateTasaImpuestos < ActiveRecord::Migration[8.0]
  def change
    create_table :tasa_impuestos do |t|
      t.string :nombre, null: false
      t.decimal :porcentaje, precision: 5, scale: 2, null: false
      t.text :descripcion
      t.boolean :activo, default: true, null: false
      t.boolean :predeterminado, default: false, null: false

      t.timestamps
    end
    
    add_index :tasa_impuestos, :nombre, unique: true
    add_index :tasa_impuestos, :activo
    add_index :tasa_impuestos, :predeterminado
  end
end
