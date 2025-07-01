class AddTasaImpuestoToFacturas < ActiveRecord::Migration[8.0]
  def change
    add_reference :facturas, :tasa_impuesto, null: true, foreign_key: true
  end
end
