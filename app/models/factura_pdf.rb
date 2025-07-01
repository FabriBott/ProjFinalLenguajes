require 'prawn'
require 'prawn/table'

class FacturaPdf < Prawn::Document
  def initialize(factura)
    super(top_margin: 70)
    @factura = factura
    header
    client_info
    invoice_details
    line_items
    totals
    footer
  end

  private

  def header
    text "FACTURA", size: 30, style: :bold, align: :center
    move_down 30
  end

  def client_info
    bounding_box([0, cursor], width: 250, height: 100) do
      text "CLIENTE:", style: :bold
      text @factura.cliente.nombre
      text "Cédula: #{@factura.cliente.cedula}"
      text "Email: #{@factura.cliente.email}" if @factura.cliente.email.present?
      text "Teléfono: #{@factura.cliente.telefono}" if @factura.cliente.telefono.present?
      
      if @factura.cliente.direccion.present?
        text "Dirección:"
        text @factura.cliente.direccion, size: 10
      end
    end
    
    move_down 20
  end

  def invoice_details
    data = [
      ["Factura #:", @factura.numero],
      ["Fecha:", @factura.fecha.strftime("%d/%m/%Y")]
    ]
    
    table(data, width: 200, column_widths: [100, 100]) do
      cells.borders = []
      cells.padding = [2, 5, 2, 5]
      column(0).font_style = :bold
    end
    
    move_down 30
  end

  def line_items
    # Calcular anchos antes del bloque de la tabla
    page_width = bounds.width
    col_widths = {
      0 => page_width * 0.45,  # Producto - 45%
      1 => page_width * 0.15,  # Cantidad - 15%
      2 => page_width * 0.20,  # Precio Unit. - 20%
      3 => page_width * 0.20   # Subtotal - 20%
    }
    
    table line_item_rows, width: page_width do
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      self.header = true
      self.row_colors = ['FFFFFF', 'F9F9F9']
      
      # Usar los anchos pre-calculados
      self.column_widths = col_widths
      
      cells.padding = [5, 5, 5, 5]
      cells.borders = [:top, :bottom]
      cells.border_width = 0.5
    end
  end

  def line_item_rows
    [['Producto', 'Cantidad', 'Precio Unit.', 'Subtotal']] +
    @factura.detalle_facturas.map do |detalle|
      [
        detalle.producto.nombre,
        detalle.cantidad.to_s,
        "¢#{number_with_delimiter(detalle.precio_unitario, delimiter: ',')}",
        "¢#{number_with_delimiter(detalle.subtotal, delimiter: ',')}"
      ]
    end
  end

  def totals
    move_down 20
    
    # Construir datos de totales
    data = [
      ['Subtotal:', "¢#{number_with_delimiter(@factura.subtotal, delimiter: ',')}"]
    ]
    
    # Agregar cada impuesto por separado
    @factura.detalle_impuestos.each do |impuesto_detalle|
      data << ["#{impuesto_detalle[:nombre]} (#{impuesto_detalle[:porcentaje]}%):", 
               "¢#{number_with_delimiter(impuesto_detalle[:monto], delimiter: ',')}"]
    end
    
    # Si hay múltiples impuestos, agregar línea de total de impuestos
    if @factura.detalle_impuestos.size > 1
      data << ['Total Impuestos:', "¢#{number_with_delimiter(@factura.impuesto, delimiter: ',')}"]
    end
    
    # Agregar total final
    data << ['TOTAL:', "¢#{number_with_delimiter(@factura.total, delimiter: ',')}"]
    
    # Crear tabla de totales sin bounding_box, directamente alineada a la derecha
    table(data, position: :right, width: 200, column_widths: [100, 100]) do
      cells.borders = []
      cells.padding = [2, 5, 2, 5]
      column(0).font_style = :bold
      column(0).align = :right
      column(1).align = :right
      
      # Hacer la última fila (total) más destacada
      row(-1).font_style = :bold
      row(-1).size = 12
      row(-1).borders = [:top]
      row(-1).border_width = 1
    end
  end

  def footer
    move_down 50
    text "Gracias por su compra", size: 12, style: :italic, align: :center
    
    # Agregar número de página
    number_pages "Página <page> de <total>", 
                 at: [bounds.right - 50, 0], 
                 width: 50, 
                 align: :right,
                 size: 8
  end

  def number_with_delimiter(number, options = {})
    delimiter = options[:delimiter] || ','
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{delimiter}").reverse
  end
end
