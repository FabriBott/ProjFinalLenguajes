# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Crear productos de ejemplo
puts "Creando productos..."

productos = [
  { nombre: "Laptop Dell Inspiron", precio: 450000.00, stock: 10 },
  { nombre: "Mouse Inalámbrico", precio: 15000.00, stock: 25 },
  { nombre: "Teclado Mecánico", precio: 35000.00, stock: 15 },
  { nombre: "Monitor 24 pulgadas", precio: 180000.00, stock: 8 },
  { nombre: "Impresora HP", precio: 120000.00, stock: 5 },
  { nombre: "Disco Duro Externo 1TB", precio: 65000.00, stock: 20 },
  { nombre: "Memoria RAM 8GB", precio: 45000.00, stock: 30 },
  { nombre: "Webcam HD", precio: 25000.00, stock: 12 }
]

productos.each do |producto_data|
  Producto.find_or_create_by(nombre: producto_data[:nombre]) do |producto|
    producto.precio = producto_data[:precio]
    producto.stock = producto_data[:stock]
  end
end

puts "#{Producto.count} productos creados."

# Crear clientes de ejemplo
puts "Creando clientes..."

clientes = [
  {
    nombre: "Juan Pérez Rodríguez",
    cedula: "112345678",
    email: "juan.perez@email.com",
    telefono: "88881234",
    direccion: "San José, Costa Rica"
  },
  {
    nombre: "María González López",
    cedula: "223456789",
    email: "maria.gonzalez@email.com",
    telefono: "88885678",
    direccion: "Cartago, Costa Rica"
  },
  {
    nombre: "Carlos Jiménez Mora",
    cedula: "134567890",
    email: "carlos.jimenez@email.com",
    telefono: "88889012",
    direccion: "Heredia, Costa Rica"
  },
  {
    nombre: "Ana Vargas Castro",
    cedula: "245678901",
    email: "ana.vargas@email.com",
    telefono: "88883456",
    direccion: "Alajuela, Costa Rica"
  }
]

clientes.each do |cliente_data|
  Cliente.find_or_create_by(cedula: cliente_data[:cedula]) do |cliente|
    cliente.nombre = cliente_data[:nombre]
    cliente.email = cliente_data[:email]
    cliente.telefono = cliente_data[:telefono]
    cliente.direccion = cliente_data[:direccion]
  end
end

puts "#{Cliente.count} clientes creados."

# Crear algunas facturas de ejemplo
puts "Creando facturas de ejemplo..."

if Cliente.any? && Producto.any?
  # Factura 1
  cliente1 = Cliente.first
  factura1 = Factura.create!(
    cliente: cliente1,
    fecha: Date.current - 5.days
  )
  
  # Agregar productos a la factura 1
  laptop = Producto.find_by(nombre: "Laptop Dell Inspiron")
  mouse = Producto.find_by(nombre: "Mouse Inalámbrico")
  
  if laptop && mouse
    factura1.detalle_facturas.create!(producto: laptop, cantidad: 1, precio_unitario: laptop.precio)
    factura1.detalle_facturas.create!(producto: mouse, cantidad: 2, precio_unitario: mouse.precio)
    factura1.calcular_totales
    factura1.save!
  end
  
  # Factura 2
  cliente2 = Cliente.second
  factura2 = Factura.create!(
    cliente: cliente2,
    fecha: Date.current - 2.days
  )
  
  # Agregar productos a la factura 2
  monitor = Producto.find_by(nombre: "Monitor 24 pulgadas")
  teclado = Producto.find_by(nombre: "Teclado Mecánico")
  
  if monitor && teclado
    factura2.detalle_facturas.create!(producto: monitor, cantidad: 1, precio_unitario: monitor.precio)
    factura2.detalle_facturas.create!(producto: teclado, cantidad: 1, precio_unitario: teclado.precio)
    factura2.calcular_totales
    factura2.save!
  end
  
  puts "#{Factura.count} facturas de ejemplo creadas."
else
  puts "No se pudieron crear facturas - faltan clientes o productos."
end

# Tasas de Impuesto
TasaImpuesto.find_or_create_by(nombre: 'IVA General') do |tasa|
  tasa.porcentaje = 13.0
  tasa.descripcion = 'Impuesto al Valor Agregado general'
  tasa.activo = true
  tasa.predeterminado = true
end

TasaImpuesto.find_or_create_by(nombre: 'IVA Reducido') do |tasa|
  tasa.porcentaje = 4.0
  tasa.descripcion = 'Impuesto al Valor Agregado reducido'
  tasa.activo = true
  tasa.predeterminado = false
end

TasaImpuesto.find_or_create_by(nombre: 'Exento') do |tasa|
  tasa.porcentaje = 0.0
  tasa.descripcion = 'Productos exentos de impuestos'
  tasa.activo = true
  tasa.predeterminado = false
end

puts "¡Datos de ejemplo creados exitosamente!"
puts "Productos: #{Producto.count}"
puts "Clientes: #{Cliente.count}"
puts "Facturas: #{Factura.count}"
