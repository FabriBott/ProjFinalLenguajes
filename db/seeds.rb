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

# Crear tasas de impuesto primero
puts "Creando tasas de impuesto..."

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

TasaImpuesto.find_or_create_by(nombre: 'Impuesto Especial') do |tasa|
  tasa.porcentaje = 5.0
  tasa.descripcion = 'Impuesto especial para ciertos productos'
  tasa.activo = true
  tasa.predeterminado = false
end

TasaImpuesto.find_or_create_by(nombre: 'Impuesto Lujo') do |tasa|
  tasa.porcentaje = 8.0
  tasa.descripcion = 'Impuesto adicional para productos de lujo'
  tasa.activo = true
  tasa.predeterminado = false
end

puts "#{TasaImpuesto.count} tasas de impuesto creadas."

# Crear algunas facturas de ejemplo
puts "Creando facturas de ejemplo..."

if Cliente.any? && Producto.any?
  # Obtener las tasas de impuesto ya creadas
  iva_general = TasaImpuesto.find_by(nombre: 'IVA General')
  iva_reducido = TasaImpuesto.find_by(nombre: 'IVA Reducido')
  impuesto_lujo = TasaImpuesto.find_by(nombre: 'Impuesto Lujo')
  impuesto_especial = TasaImpuesto.find_by(nombre: 'Impuesto Especial')

  # Factura 1 - Solo IVA General (caso básico)
  cliente1 = Cliente.first
  factura1 = Factura.new(cliente: cliente1, fecha: Date.current - 5.days)
  # Generar número manualmente ya que salteamos validaciones
  ultimo_numero = Factura.maximum(:numero)
  numero_int = ultimo_numero ? ultimo_numero.gsub(/\D/, '').to_i + 1 : 1
  factura1.numero = "FAC-#{numero_int.to_s.rjust(6, '0')}"
  factura1.subtotal = 0
  factura1.impuesto = 0
  factura1.total = 0
  factura1.save!(validate: false)
  
  # Agregar productos a la factura 1
  laptop = Producto.find_by(nombre: "Laptop Dell Inspiron")
  mouse = Producto.find_by(nombre: "Mouse Inalámbrico")
  
  if laptop && mouse
    factura1.detalle_facturas.create!(producto: laptop, cantidad: 1, precio_unitario: laptop.precio)
    factura1.detalle_facturas.create!(producto: mouse, cantidad: 2, precio_unitario: mouse.precio)
    
    # Limpiar cualquier tasa existente y asignar solo IVA General
    factura1.factura_tasa_impuestos.destroy_all
    factura1.factura_tasa_impuestos.create!(tasa_impuesto: iva_general)
    factura1.calcular_totales
    factura1.save!(validate: false)
  end
  
  # Factura 2 - IVA General + Impuesto Lujo (múltiples tasas)
  cliente2 = Cliente.second
  factura2 = Factura.new(cliente: cliente2, fecha: Date.current - 3.days)
  # Generar número manualmente
  ultimo_numero = Factura.maximum(:numero)
  numero_int = ultimo_numero ? ultimo_numero.gsub(/\D/, '').to_i + 1 : 2
  factura2.numero = "FAC-#{numero_int.to_s.rjust(6, '0')}"
  factura2.subtotal = 0
  factura2.impuesto = 0
  factura2.total = 0
  factura2.save!(validate: false)
  
  # Agregar productos a la factura 2 (productos de lujo)
  monitor = Producto.find_by(nombre: "Monitor 24 pulgadas")
  
  if monitor
    factura2.detalle_facturas.create!(producto: monitor, cantidad: 1, precio_unitario: monitor.precio)
    
    # Limpiar y asignar múltiples tasas: IVA General + Impuesto Lujo
    factura2.factura_tasa_impuestos.destroy_all
    factura2.factura_tasa_impuestos.create!(tasa_impuesto: iva_general)
    factura2.factura_tasa_impuestos.create!(tasa_impuesto: impuesto_lujo)
    factura2.calcular_totales
    factura2.save!(validate: false)
  end
  
  # Factura 3 - IVA Reducido + Impuesto Especial (otra combinación)
  cliente3 = Cliente.third
  factura3 = Factura.new(cliente: cliente3, fecha: Date.current - 1.day)
  # Generar número manualmente
  ultimo_numero = Factura.maximum(:numero)
  numero_int = ultimo_numero ? ultimo_numero.gsub(/\D/, '').to_i + 1 : 3
  factura3.numero = "FAC-#{numero_int.to_s.rjust(6, '0')}"
  factura3.subtotal = 0
  factura3.impuesto = 0
  factura3.total = 0
  factura3.save!(validate: false)
  
  # Agregar productos a la factura 3
  teclado = Producto.find_by(nombre: "Teclado Mecánico")
  memoria = Producto.find_by(nombre: "Memoria RAM 8GB")
  
  if teclado && memoria
    factura3.detalle_facturas.create!(producto: teclado, cantidad: 1, precio_unitario: teclado.precio)
    factura3.detalle_facturas.create!(producto: memoria, cantidad: 2, precio_unitario: memoria.precio)
    
    # Limpiar y asignar múltiples tasas: IVA Reducido + Impuesto Especial
    factura3.factura_tasa_impuestos.destroy_all
    factura3.factura_tasa_impuestos.create!(tasa_impuesto: iva_reducido)
    factura3.factura_tasa_impuestos.create!(tasa_impuesto: impuesto_especial)
    factura3.calcular_totales
    factura3.save!(validate: false)
  end
  
  # Factura 4 - Triple impuesto (caso extremo de prueba)
  cliente4 = Cliente.fourth || Cliente.first
  factura4 = Factura.new(cliente: cliente4, fecha: Date.current)
  # Generar número manualmente
  ultimo_numero = Factura.maximum(:numero)
  numero_int = ultimo_numero ? ultimo_numero.gsub(/\D/, '').to_i + 1 : 4
  factura4.numero = "FAC-#{numero_int.to_s.rjust(6, '0')}"
  factura4.subtotal = 0
  factura4.impuesto = 0
  factura4.total = 0
  factura4.save!(validate: false)
  
  # Agregar productos caros para la factura 4
  impresora = Producto.find_by(nombre: "Impresora HP")
  disco = Producto.find_by(nombre: "Disco Duro Externo 1TB")
  
  if impresora && disco
    factura4.detalle_facturas.create!(producto: impresora, cantidad: 1, precio_unitario: impresora.precio)
    factura4.detalle_facturas.create!(producto: disco, cantidad: 1, precio_unitario: disco.precio)
    
    # Limpiar y asignar tres tasas: IVA General + Impuesto Lujo + Impuesto Especial
    factura4.factura_tasa_impuestos.destroy_all
    factura4.factura_tasa_impuestos.create!(tasa_impuesto: iva_general)
    factura4.factura_tasa_impuestos.create!(tasa_impuesto: impuesto_lujo)
    factura4.factura_tasa_impuestos.create!(tasa_impuesto: impuesto_especial)
    factura4.calcular_totales
    factura4.save!(validate: false)
  end
  
  puts "#{Factura.count} facturas de ejemplo creadas:"
  puts "- Factura #{factura1.numero}: Solo IVA General (13%)"
  puts "- Factura #{factura2.numero}: IVA General + Impuesto Lujo (13% + 8%)"
  puts "- Factura #{factura3.numero}: IVA Reducido + Impuesto Especial (4% + 5%)"
  puts "- Factura #{factura4.numero}: IVA General + Impuesto Lujo + Impuesto Especial (13% + 8% + 5%)"
else
  puts "No se pudieron crear facturas - faltan clientes o productos."
end

puts "¡Datos de ejemplo creados exitosamente!"
puts "Productos: #{Producto.count}"
puts "Clientes: #{Cliente.count}"
puts "Tasas de Impuesto: #{TasaImpuesto.count}"
puts "Facturas: #{Factura.count}"
