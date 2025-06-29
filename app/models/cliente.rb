class Cliente < ApplicationRecord
  has_many :facturas, dependent: :destroy
  
  validates :nombre, presence: true
  validates :cedula, presence: true, uniqueness: true, 
            format: { 
              with: /\A\d{9,12}\z/, 
              message: "debe contener solo números (9 dígitos para cédula nacional o 12 para DIMEX)" 
            }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :telefono, format: { 
              with: /\A\d{8}\z/, 
              message: "debe contener exactamente 8 dígitos" 
            }, allow_blank: true
  
  # Scopes para soft delete
  scope :activos, -> { where(activo: true) }
  scope :inactivos, -> { where(activo: false) }
  
  def nombre_completo
    "#{nombre} (#{cedula})"
  end
  
  def desactivar!
    update!(activo: false)
  end
  
  def activar!
    update!(activo: true)
  end
  
  def puede_ser_eliminado?
    facturas.empty?
  end
  
  def estado_texto
    activo? ? "Activo" : "Inactivo"
  end
end
