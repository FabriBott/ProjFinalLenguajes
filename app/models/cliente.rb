class Cliente < ApplicationRecord
  has_many :facturas, dependent: :destroy
  
  validates :nombre, presence: true
  validates :cedula, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  def nombre_completo
    "#{nombre} (#{cedula})"
  end
end
