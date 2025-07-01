class Producto < ApplicationRecord
  has_many :detalle_facturas, dependent: :restrict_with_exception
  has_many :facturas, through: :detalle_facturas
  
  validates :nombre, presence: true
  validates :precio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  
  scope :con_stock, -> { where('stock > 0') }
  
  def tiene_stock?(cantidad)
    stock >= cantidad
  end
  
  def reducir_stock(cantidad)
    raise "No hay suficiente stock" if cantidad > stock
    update!(stock: stock - cantidad)
  end
  
  def aumentar_stock(cantidad)
    update!(stock: stock + cantidad)
  end
  
  def sin_stock?
    stock.nil? || stock <= 0
  end
  
  def stock_bajo?
    stock_minimo = 5 # Umbral configurable
    !sin_stock? && stock <= stock_minimo
  end
  
  def stock_critico?
    stock_minimo_critico = 2
    !sin_stock? && stock <= stock_minimo_critico
  end
  
  def estado_stock
    return :sin_stock if sin_stock?
    return :critico if stock_critico?
    return :bajo if stock_bajo?
    :normal
  end
  
  def badge_stock_class
    case estado_stock
    when :sin_stock
      'badge bg-danger'
    when :critico
      'badge bg-warning text-dark'
    when :bajo
      'badge bg-info'
    else
      'badge bg-success'
    end
  end
  
  def texto_estado_stock
    case estado_stock
    when :sin_stock
      'Sin Stock'
    when :critico
      'Stock Crítico'
    when :bajo
      'Stock Bajo'
    else
      'Stock Normal'
    end
  end
  
  # Scopes para consultas
  scope :con_stock_bajo, -> { where('stock > 0 AND stock <= 5') }
  scope :con_stock_critico, -> { where('stock > 0 AND stock <= 2') }
  scope :sin_stock, -> { where('stock IS NULL OR stock <= 0') }
end
