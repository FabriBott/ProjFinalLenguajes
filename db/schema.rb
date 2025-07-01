# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_01_050544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clientes", force: :cascade do |t|
    t.string "nombre"
    t.string "cedula"
    t.string "email"
    t.string "telefono"
    t.text "direccion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "activo", default: true, null: false
  end

  create_table "detalle_facturas", force: :cascade do |t|
    t.bigint "factura_id", null: false
    t.bigint "producto_id", null: false
    t.integer "cantidad"
    t.decimal "precio_unitario"
    t.decimal "subtotal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factura_id"], name: "index_detalle_facturas_on_factura_id"
    t.index ["producto_id"], name: "index_detalle_facturas_on_producto_id"
  end

  create_table "factura_tasa_impuestos", force: :cascade do |t|
    t.bigint "factura_id", null: false
    t.bigint "tasa_impuesto_id", null: false
    t.decimal "monto_impuesto", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factura_id", "tasa_impuesto_id"], name: "index_factura_tasa_impuestos_unique", unique: true
    t.index ["factura_id"], name: "index_factura_tasa_impuestos_on_factura_id"
    t.index ["tasa_impuesto_id"], name: "index_factura_tasa_impuestos_on_tasa_impuesto_id"
  end

  create_table "facturas", force: :cascade do |t|
    t.string "numero"
    t.date "fecha"
    t.bigint "cliente_id", null: false
    t.decimal "subtotal"
    t.decimal "impuesto"
    t.decimal "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tasa_impuesto_id"
    t.index ["cliente_id"], name: "index_facturas_on_cliente_id"
    t.index ["tasa_impuesto_id"], name: "index_facturas_on_tasa_impuesto_id"
  end

  create_table "movimiento_stocks", force: :cascade do |t|
    t.bigint "producto_id", null: false
    t.string "tipo_movimiento", null: false
    t.integer "cantidad", null: false
    t.integer "cantidad_anterior", null: false
    t.integer "cantidad_nueva", null: false
    t.string "motivo", null: false
    t.text "observaciones"
    t.string "usuario", null: false
    t.datetime "fecha_movimiento", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fecha_movimiento"], name: "index_movimiento_stocks_on_fecha_movimiento"
    t.index ["producto_id", "fecha_movimiento"], name: "index_movimiento_stocks_on_producto_id_and_fecha_movimiento"
    t.index ["producto_id"], name: "index_movimiento_stocks_on_producto_id"
    t.index ["tipo_movimiento"], name: "index_movimiento_stocks_on_tipo_movimiento"
  end

  create_table "productos", force: :cascade do |t|
    t.string "nombre"
    t.decimal "precio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stock", default: 0, null: false
    t.index ["stock"], name: "index_productos_on_stock"
  end

  create_table "tasa_impuestos", force: :cascade do |t|
    t.string "nombre", null: false
    t.decimal "porcentaje", precision: 5, scale: 2, null: false
    t.text "descripcion"
    t.boolean "activo", default: true, null: false
    t.boolean "predeterminado", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activo"], name: "index_tasa_impuestos_on_activo"
    t.index ["nombre"], name: "index_tasa_impuestos_on_nombre", unique: true
    t.index ["predeterminado"], name: "index_tasa_impuestos_on_predeterminado"
  end

  add_foreign_key "detalle_facturas", "facturas"
  add_foreign_key "detalle_facturas", "productos"
  add_foreign_key "factura_tasa_impuestos", "facturas"
  add_foreign_key "factura_tasa_impuestos", "tasa_impuestos"
  add_foreign_key "facturas", "clientes"
  add_foreign_key "facturas", "tasa_impuestos"
  add_foreign_key "movimiento_stocks", "productos"
end
