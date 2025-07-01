class Factura < ApplicationRecord
  belongs_to :cliente
  belongs_to :tasa_impuesto, optional: true
  has_many :detalle_facturas, dependent: :destroy
  has_many :productos, through: :detalle_facturas
  
  validates :fecha, presence: true
  validates :numero, presence: true, uniqueness: true
  validates :subtotal, :impuesto, :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :generar_numero, on: :create
  before_validation :set_fecha, on: :create
  before_validation :set_tasa_impuesto_predeterminada, on: :create
  before_validation :inicializar_totales, on: :create
  before_save :calcular_totales
  
  scope :por_fecha, -> { order(fecha: :desc) }
  
  def calcular_totales
    self.subtotal = detalle_facturas.sum(&:subtotal)
    if tasa_impuesto
      self.impuesto = tasa_impuesto.calcular_impuesto(subtotal)
    else
      self.impuesto = subtotal * 0.13 # 13% de impuesto por defecto como fallback
    end
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
  
  def set_tasa_impuesto_predeterminada
    self.tasa_impuesto ||= TasaImpuesto.tasa_predeterminada
  end
  
  def inicializar_totales
    self.subtotal ||= 0
    self.impuesto ||= 0
    self.total ||= 0
  end
end
