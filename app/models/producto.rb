class Producto < ApplicationRecord
  has_many :detalle_facturas, dependent: :restrict_with_exception
  has_many :facturas, through: :detalle_facturas
  has_many :movimiento_stocks, dependent: :destroy
  
  validates :nombre, presence: true
  validates :precio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  
  scope :con_stock, -> { where('stock > 0') }
  
  # Callbacks para registrar movimientos de stock
  after_create :registrar_inventario_inicial, if: :stock_positivo?
  # after_update :registrar_cambio_stock, if: :saved_change_to_stock? # Deshabilitado para manejar desde controlador
  
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
  
  # Métodos para registrar movimientos con contexto
  def registrar_entrada(cantidad, motivo, observaciones = nil, usuario = 'Sistema')
    MovimientoStock.registrar_movimiento(self, 'entrada', cantidad, motivo, observaciones, usuario)
  end
  
  def registrar_salida(cantidad, motivo, observaciones = nil, usuario = 'Sistema')
    MovimientoStock.registrar_movimiento(self, 'salida', cantidad, motivo, observaciones, usuario)
  end
  
  def registrar_ajuste(nueva_cantidad, motivo, observaciones = nil, usuario = 'Sistema')
    MovimientoStock.registrar_movimiento(self, 'ajuste', nueva_cantidad, motivo, observaciones, usuario)
  end
  
  private
  
  def stock_positivo?
    stock&.positive?
  end
  
  def registrar_inventario_inicial
    return unless stock&.positive?
    
    MovimientoStock.create!(
      producto: self,
      tipo_movimiento: 'entrada',
      cantidad: stock,
      cantidad_anterior: 0,
      cantidad_nueva: stock,
      motivo: 'Inventario inicial',
      observaciones: "Stock inicial al crear el producto '#{nombre}'",
      usuario: 'Sistema',
      fecha_movimiento: Time.current
    )
  end
  
  def registrar_cambio_stock
    stock_anterior = saved_change_to_stock[0] || 0
    stock_actual = saved_change_to_stock[1] || 0
    diferencia = stock_actual - stock_anterior
    
    return if diferencia == 0
    
    if diferencia > 0
      # Aumento de stock
      MovimientoStock.create!(
        producto: self,
        tipo_movimiento: 'entrada',
        cantidad: diferencia,
        cantidad_anterior: stock_anterior,
        cantidad_nueva: stock_actual,
        motivo: 'Ajuste manual',
        observaciones: "Stock actualizado manualmente desde #{stock_anterior} a #{stock_actual}",
        usuario: 'Usuario',
        fecha_movimiento: Time.current
      )
    else
      # Disminución de stock
      MovimientoStock.create!(
        producto: self,
        tipo_movimiento: 'salida',
        cantidad: diferencia.abs,
        cantidad_anterior: stock_anterior,
        cantidad_nueva: stock_actual,
        motivo: 'Ajuste manual',
        observaciones: "Stock actualizado manualmente desde #{stock_anterior} a #{stock_actual}",
        usuario: 'Usuario',
        fecha_movimiento: Time.current
      )
    end
  end
end
