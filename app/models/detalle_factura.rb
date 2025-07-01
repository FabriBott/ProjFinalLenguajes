class DetalleFactura < ApplicationRecord
  belongs_to :factura
  belongs_to :producto
  
  validates :cantidad, presence: true, numericality: { greater_than: 0 }
  validates :precio_unitario, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :validar_stock_disponible
  
  before_validation :set_precio_unitario, on: :create
  before_validation :inicializar_subtotal, on: :create
  before_save :calcular_subtotal
  
  private
  
  def set_precio_unitario
    self.precio_unitario ||= producto&.precio
  end
  
  def inicializar_subtotal
    self.subtotal ||= 0
  end
  
  def calcular_subtotal
    self.subtotal = (cantidad || 0) * (precio_unitario || 0)
  end
  
  def validar_stock_disponible
    return unless producto && cantidad
    
    unless producto.tiene_stock?(cantidad)
      errors.add(:cantidad, "No hay suficiente stock. Stock disponible: #{producto.stock}")
    end
  end
end
