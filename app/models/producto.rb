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
    stock <= 0
  end
end
