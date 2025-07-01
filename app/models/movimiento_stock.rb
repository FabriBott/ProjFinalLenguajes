class MovimientoStock < ApplicationRecord
  belongs_to :producto
  
  validates :tipo_movimiento, presence: true, inclusion: { in: %w[entrada salida ajuste] }
  validates :cantidad, presence: true, numericality: { greater_than: 0 }
  validates :cantidad_anterior, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cantidad_nueva, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :motivo, presence: true
  validates :usuario, presence: true
  validates :fecha_movimiento, presence: true
  
  scope :entradas, -> { where(tipo_movimiento: 'entrada') }
  scope :salidas, -> { where(tipo_movimiento: 'salida') }
  scope :ajustes, -> { where(tipo_movimiento: 'ajuste') }
  scope :por_producto, ->(producto_id) { where(producto_id: producto_id) }
  scope :por_fecha, ->(fecha_inicio, fecha_fin) { where(fecha_movimiento: fecha_inicio..fecha_fin) }
  scope :recientes, -> { order(fecha_movimiento: :desc) }
  
  # Motivos predefinidos
  MOTIVOS_ENTRADA = [
    'Compra a proveedor',
    'Devolución de cliente',
    'Inventario inicial',
    'Transferencia de sucursal',
    'Producción interna',
    'Otros'
  ].freeze
  
  MOTIVOS_SALIDA = [
    'Venta',
    'Devolución a proveedor',
    'Producto dañado/vencido',
    'Transferencia a sucursal',
    'Uso interno',
    'Muestra gratis',
    'Pérdida/robo',
    'Otros'
  ].freeze
  
  MOTIVOS_AJUSTE = [
    'Corrección de inventario',
    'Diferencia de conteo',
    'Error de sistema',
    'Auditoría',
    'Otros'
  ].freeze
  
  def self.motivos_por_tipo(tipo)
    case tipo
    when 'entrada'
      MOTIVOS_ENTRADA
    when 'salida'
      MOTIVOS_SALIDA
    when 'ajuste'
      MOTIVOS_AJUSTE
    else
      []
    end
  end
  
  def entrada?
    tipo_movimiento == 'entrada'
  end
  
  def salida?
    tipo_movimiento == 'salida'
  end
  
  def ajuste?
    tipo_movimiento == 'ajuste'
  end
  
  def badge_class
    case tipo_movimiento
    when 'entrada'
      'badge bg-success'
    when 'salida'
      'badge bg-danger'
    when 'ajuste'
      'badge bg-warning text-dark'
    else
      'badge bg-secondary'
    end
  end
  
  def diferencia
    cantidad_nueva - cantidad_anterior
  end
  
  def diferencia_absoluta
    diferencia.abs
  end
  
  def diferencia_con_signo
    case tipo_movimiento
    when 'entrada'
      "+#{cantidad}"
    when 'salida'
      "-#{cantidad}"
    when 'ajuste'
      diferencia >= 0 ? "+#{diferencia_absoluta}" : "-#{diferencia_absoluta}"
    end
  end
  
  # Método para registrar un movimiento y actualizar el stock del producto
  def self.registrar_movimiento(producto, tipo, cantidad, motivo, observaciones = nil, usuario = 'Sistema')
    ActiveRecord::Base.transaction do
      stock_anterior = producto.stock || 0
      
      case tipo
      when 'entrada'
        nuevo_stock = stock_anterior + cantidad
      when 'salida'
        raise "No hay suficiente stock. Stock actual: #{stock_anterior}, cantidad solicitada: #{cantidad}" if stock_anterior < cantidad
        nuevo_stock = stock_anterior - cantidad
      when 'ajuste'
        nuevo_stock = cantidad # En ajustes, cantidad representa el stock final deseado
        cantidad = (nuevo_stock - stock_anterior).abs
      else
        raise "Tipo de movimiento inválido: #{tipo}"
      end
      
      # Crear el registro del movimiento
      movimiento = create!(
        producto: producto,
        tipo_movimiento: tipo,
        cantidad: cantidad,
        cantidad_anterior: stock_anterior,
        cantidad_nueva: nuevo_stock,
        motivo: motivo,
        observaciones: observaciones,
        usuario: usuario,
        fecha_movimiento: Time.current
      )
      
      # Actualizar el stock del producto
      producto.update!(stock: nuevo_stock)
      
      movimiento
    end
  end
  
  def descripcion_completa
    base = "#{tipo_movimiento.capitalize}: #{diferencia_con_signo} unidades"
    base += " (#{motivo})"
    base += " - #{observaciones}" if observaciones.present?
    base
  end
end

