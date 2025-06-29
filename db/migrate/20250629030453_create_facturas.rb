class CreateFacturas < ActiveRecord::Migration[8.0]
  def change
    create_table :facturas do |t|
      t.string :numero
      t.date :fecha
      t.references :cliente, null: false, foreign_key: true
      t.decimal :subtotal
      t.decimal :impuesto
      t.decimal :total

      t.timestamps
    end
  end
end
