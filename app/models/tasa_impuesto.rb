class TasaImpuesto < ApplicationRecord
  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
  validates :porcentaje, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  
  scope :activos, -> { where(activo: true) }
  scope :predeterminado, -> { where(predeterminado: true) }
  
  before_save :ensure_single_default
  
  def self.tasa_predeterminada
    predeterminado.activos.first || activos.first
  end
  
  def porcentaje_decimal
    porcentaje / 100.0
  end
  
  def calcular_impuesto(monto)
    monto * porcentaje_decimal
  end
  
  def puede_ser_eliminado?
    # Verificar si hay facturas que usen esta tasa
    # Por ahora retornamos true, luego lo modificaremos cuando agreguemos la relación
    true
  end
  
  private
  
  def ensure_single_default
    if predeterminado? && predeterminado_changed?
      TasaImpuesto.where.not(id: id).update_all(predeterminado: false)
    end
  end
end
