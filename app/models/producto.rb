class Producto < ApplicationRecord
    has_many :detalle_facturas, dependent: :restrict_with_exception
    has_many :facturas, through: :detalle_facturas
    
    validates :nombre, presence: true
    validates :precio, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
  