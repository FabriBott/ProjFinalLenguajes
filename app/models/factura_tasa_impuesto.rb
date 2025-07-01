class FacturaTasaImpuesto < ApplicationRecord
  belongs_to :factura
  belongs_to :tasa_impuesto
  
  validates :factura_id, uniqueness: { scope: :tasa_impuesto_id }
  validates :monto_impuesto, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Calcular el monto de impuesto basado en el subtotal de la factura
  def calcular_monto_impuesto(subtotal)
    self.monto_impuesto = tasa_impuesto.calcular_impuesto(subtotal)
  end
end
