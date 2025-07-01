class MigrateExistingFacturasToMultipleTaxes < ActiveRecord::Migration[8.0]
  def up
    # Migrar facturas existentes con tasa_impuesto_id al nuevo sistema
    Factura.where.not(tasa_impuesto_id: nil).find_each do |factura|
      # Crear entrada en la tabla intermedia
      FacturaTasaImpuesto.create!(
        factura: factura,
        tasa_impuesto_id: factura.tasa_impuesto_id,
        monto_impuesto: factura.impuesto
      )
    end
  end
  
  def down
    # Eliminar todas las entradas de la tabla intermedia
    FacturaTasaImpuesto.delete_all
  end
end
