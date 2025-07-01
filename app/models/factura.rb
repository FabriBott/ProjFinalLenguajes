class Factura < ApplicationRecord
  belongs_to :cliente
  belongs_to :tasa_impuesto, optional: true # Mantenemos por compatibilidad temporal
  has_many :detalle_facturas, dependent: :destroy
  has_many :productos, through: :detalle_facturas
  has_many :factura_tasa_impuestos, dependent: :destroy
  has_many :multiples_tasas_impuesto, through: :factura_tasa_impuestos, source: :tasa_impuesto
  
  validates :fecha, presence: true
  validates :numero, presence: true, uniqueness: true
  validates :subtotal, :impuesto, :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :generar_numero, on: :create
  before_validation :set_fecha, on: :create
  before_validation :set_tasa_impuesto_predeterminada, on: :create
  before_validation :inicializar_totales, on: :create
  before_save :calcular_totales
  after_create :setup_default_tax_association
  
  scope :por_fecha, -> { order(fecha: :desc) }
  
  # Getter virtual para IDs de tasas de impuesto
  def tasa_impuesto_ids
    multiples_tasas_impuesto.pluck(:id)
  end
  
  # Setter virtual para IDs de tasas de impuesto
  def tasa_impuesto_ids=(ids)
    return if ids.blank? || (ids.is_a?(Array) && ids.all?(&:blank?))
    
    ids = ids.reject(&:blank?).map(&:to_i) if ids.is_a?(Array)
    
    # Limpiar asociaciones existentes solo si no estamos en una nueva instancia
    factura_tasa_impuestos.destroy_all unless new_record?
    
    # Crear nuevas asociaciones
    if ids.present?
      ids.each do |tasa_id|
        tasa = TasaImpuesto.find(tasa_id)
        if new_record?
          factura_tasa_impuestos.build(tasa_impuesto: tasa)
        else
          factura_tasa_impuestos.create!(tasa_impuesto: tasa)
        end
      end
    end
  end
  
  
  def calcular_totales
    self.subtotal = detalle_facturas.sum(&:subtotal)
    
    # Solo calcular impuestos si hay detalles
    if detalle_facturas.any?
      # Calcular impuestos usando las múltiples tasas
      if factura_tasa_impuestos.loaded? ? factura_tasa_impuestos.any? : factura_tasa_impuestos.exists?
        self.impuesto = 0
        factura_tasa_impuestos.includes(:tasa_impuesto).each do |fti|
          monto_impuesto = fti.tasa_impuesto.calcular_impuesto(subtotal)
          self.impuesto += monto_impuesto
        end
      elsif tasa_impuesto # Fallback para compatibilidad
        self.impuesto = tasa_impuesto.calcular_impuesto(subtotal)
      else
        self.impuesto = subtotal * 0.13 # 13% de impuesto por defecto como fallback
      end
    else
      self.impuesto = 0
    end
    
    self.total = subtotal + impuesto
  end
  
  # Método para obtener el detalle de impuestos por tasa
  def detalle_impuestos
    if factura_tasa_impuestos.exists?
      factura_tasa_impuestos.includes(:tasa_impuesto).map do |fti|
        # Siempre calcular el monto basado en el subtotal actual
        monto_calculado = fti.tasa_impuesto.calcular_impuesto(subtotal)
        {
          nombre: fti.tasa_impuesto.nombre,
          porcentaje: fti.tasa_impuesto.porcentaje.to_f,
          monto: monto_calculado
        }
      end
    elsif tasa_impuesto
      [{
        nombre: tasa_impuesto.nombre,
        porcentaje: tasa_impuesto.porcentaje.to_f,
        monto: tasa_impuesto.calcular_impuesto(subtotal)
      }]
    else
      [{
        nombre: "IVA General",
        porcentaje: 13.0,
        monto: subtotal * 0.13
      }]
    end
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
    return if tasa_impuesto.present? # Si ya tiene una tasa asignada, no cambiarla
    
    tasa_default = TasaImpuesto.tasa_predeterminada
    if tasa_default
      self.tasa_impuesto = tasa_default
    end
  end
  
  def inicializar_totales
    self.subtotal ||= 0
    self.impuesto ||= 0
    self.total ||= 0
  end
  
  def setup_default_tax_association
    # Solo crear la asociación por defecto si no hay tasas múltiples ya asignadas
    if factura_tasa_impuestos.empty?
      if tasa_impuesto.present?
        # Usar la tasa asignada directamente
        factura_tasa_impuestos.create!(tasa_impuesto: tasa_impuesto)
      else
        # Buscar la tasa predeterminada si no hay ninguna asignada
        tasa_default = TasaImpuesto.tasa_predeterminada
        if tasa_default
          self.update_column(:tasa_impuesto_id, tasa_default.id)
          factura_tasa_impuestos.create!(tasa_impuesto: tasa_default)
        end
      end
    end
  end
end
