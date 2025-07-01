class TasaImpuesto < ApplicationRecord
  has_many :facturas, dependent: :nullify # Relación original para compatibilidad
  has_many :factura_tasa_impuestos, dependent: :destroy
  has_many :facturas_multiples, through: :factura_tasa_impuestos, source: :factura
  
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
    # Verificar tanto en la relación original como en la nueva tabla intermedia
    !facturas.exists? && !factura_tasa_impuestos.exists?
  end
  
  private
  
  def ensure_single_default
    if predeterminado? && predeterminado_changed?
      TasaImpuesto.where.not(id: id).update_all(predeterminado: false)
    end
  end
end
