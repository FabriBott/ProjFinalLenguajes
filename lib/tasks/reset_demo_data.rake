namespace :demo do
  desc "Reset and recreate demo data"
  task reset: :environment do
    puts "🗑️  Eliminando datos existentes..."
    
    # Eliminar en el orden correcto para evitar problemas de foreign keys
    MovimientoStock.destroy_all
    DetalleFactura.destroy_all
    Factura.destroy_all
    Producto.destroy_all
    Cliente.destroy_all
    TasaImpuesto.destroy_all
    
    puts "✅ Datos eliminados"
    
    # Reset de secuencias si es necesario (para PostgreSQL)
    if Rails.env.development?
      ActiveRecord::Base.connection.reset_pk_sequence!('movimiento_stocks')
      ActiveRecord::Base.connection.reset_pk_sequence!('detalle_facturas')
      ActiveRecord::Base.connection.reset_pk_sequence!('facturas')
      ActiveRecord::Base.connection.reset_pk_sequence!('productos')
      ActiveRecord::Base.connection.reset_pk_sequence!('clientes')
      ActiveRecord::Base.connection.reset_pk_sequence!('tasa_impuestos')
    end
    
    puts "🌱 Recreando datos de demostración..."
    
    # Ejecutar seeds
    load Rails.root.join('db', 'seeds.rb')
    
    puts "🎉 ¡Datos de demostración recreados exitosamente!"
  end
  
  desc "Show current data statistics"
  task stats: :environment do
    puts "📊 Estadísticas de datos actuales:"
    puts "   Productos: #{Producto.count}"
    puts "   Clientes: #{Cliente.count}"
    puts "   Facturas: #{Factura.count}"
    puts "   Movimientos de Stock: #{MovimientoStock.count}"
    puts "   Tasas de Impuesto: #{TasaImpuesto.count}"
    
    if MovimientoStock.any?
      puts "\n📦 Movimientos por tipo:"
      MovimientoStock.group(:tipo_movimiento).count.each do |tipo, cantidad|
        puts "   #{tipo.capitalize}: #{cantidad}"
      end
    end
    
    if Producto.any?
      puts "\n🏷️  Estado de stock:"
      puts "   Con stock normal: #{Producto.joins(:movimiento_stocks).group('productos.id').having('SUM(CASE WHEN movimiento_stocks.tipo_movimiento = \'entrada\' THEN movimiento_stocks.cantidad WHEN movimiento_stocks.tipo_movimiento = \'salida\' THEN -movimiento_stocks.cantidad ELSE 0 END) > 5').count.count}"
      puts "   Con stock bajo: #{Producto.con_stock_bajo.count}"
      puts "   Sin stock: #{Producto.sin_stock.count}"
    end
  end
end

