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
  
  def nombre_completo
    "#{nombre} (#{cedula})"
  end
end
