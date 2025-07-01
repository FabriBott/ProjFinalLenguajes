puts "=== Estado de la Base de Datos ==="
puts "Clientes: #{Cliente.count}"
puts "Productos: #{Producto.count}"
puts "Facturas: #{Factura.count}"
puts "Tasas de Impuesto: #{TasaImpuesto.count}"

if TasaImpuesto.count > 0
  puts "\n=== Tasas de Impuesto ===" 
  TasaImpuesto.all.each do |tasa|
    puts "- #{tasa.nombre}: #{tasa.porcentaje}% (#{tasa.activo? ? 'Activa' : 'Inactiva'}#{tasa.predeterminado? ? ', Predeterminada' : ''})"
  end
end

if Cliente.count > 0
  puts "\n=== Clientes (primeros 5) ==="
  Cliente.limit(5).each do |cliente|
    puts "- #{cliente.nombre} #{cliente.apellidos} (#{cliente.activo? ? 'Activo' : 'Inactivo'})"
  end
end

if Producto.count > 0
  puts "\n=== Productos (primeros 5) ==="
  Producto.limit(5).each do |producto|
    puts "- #{producto.nombre}: ₡#{producto.precio}"
  end
end

