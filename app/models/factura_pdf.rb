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
    move_down 20
    
    text "Empresa XYZ", size: 16, style: :bold
    text "Dirección: Calle Principal #123"
    text "Teléfono: (555) 123-4567"
    text "Email: info@empresa.com"
    
    move_down 30
  end

  def client_info
    bounding_box([bounds.width - 250, cursor], width: 250, height: 100) do
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
    
    move_down 120
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
    table line_item_rows do
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      self.header = true
      self.row_colors = ['FFFFFF', 'F9F9F9']
      self.width = bounds.width
      
      column(0).width = 200  # Producto
      column(1).width = 80   # Cantidad
      column(2).width = 100  # Precio Unit.
      column(3).width = 100  # Subtotal
      
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
        "₡#{number_with_delimiter(detalle.precio_unitario, delimiter: ',')}",
        "₡#{number_with_delimiter(detalle.subtotal, delimiter: ',')}"
      ]
    end
  end

  def totals
    move_down 20
    
    # Crear tabla de totales alineada a la derecha
    bounding_box([bounds.width - 200, cursor], width: 200, height: 80) do
      data = [
        ['Subtotal:', "₡#{number_with_delimiter(@factura.subtotal, delimiter: ',')}"],
        ['Impuesto (13%):', "₡#{number_with_delimiter(@factura.impuesto, delimiter: ',')}"],
        ['TOTAL:', "₡#{number_with_delimiter(@factura.total, delimiter: ',')}"]
      ]
      
      table(data, width: 200, column_widths: [100, 100]) do
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
