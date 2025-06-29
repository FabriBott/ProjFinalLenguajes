class CreateClientes < ActiveRecord::Migration[8.0]
  def change
    create_table :clientes do |t|
      t.string :nombre
      t.string :cedula
      t.string :email
      t.string :telefono
      t.text :direccion

      t.timestamps
    end
  end
end
