class Factura < ApplicationRecord
  belongs_to :cliente
  has_many :detalle_facturas, dependent: :destroy
  has_many :productos, through: :detalle_facturas
  
  validates :fecha, presence: true
  validates :numero, presence: true, uniqueness: true
  validates :subtotal, :impuesto, :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :generar_numero, on: :create
  before_validation :set_fecha, on: :create
  before_save :calcular_totales
  
  scope :por_fecha, -> { order(fecha: :desc) }
  
  def calcular_totales
    self.subtotal = detalle_facturas.sum(&:subtotal)
    self.impuesto = subtotal * 0.13 # 13% de impuesto por defecto
    self.total = subtotal + impuesto
  end
  
  private
  
  def generar_numero
    return if numero.present?
    
    ultimo_numero = Factura.maximum(:numero)
    if ultimo_numero
      numero_int = ultimo_numero.gsub(/\D/, '').to_i + 1
    else
      numero_int = 1
    end
    self.numero = "FAC-#{numero_int.to_s.rjust(6, '0')}"
  end
  
  def set_fecha
    self.fecha ||= Date.current
  end
end
