class AddActivoToClientes < ActiveRecord::Migration[8.0]
  def change
    add_column :clientes, :activo, :boolean, default: true, null: false
  end
end
