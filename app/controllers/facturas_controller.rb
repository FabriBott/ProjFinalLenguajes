class FacturasController < ApplicationController
  before_action :set_factura, only: [:show]

  def index
    @facturas = Factura.includes(:cliente).por_fecha
  end

  def show
    respond_to do |format|
      format.html
      format.pdf do
        pdf = FacturaPdf.new(@factura)
        send_data pdf.render, 
                  filename: "factura_#{@factura.numero}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def new
    @factura = Factura.new
    @clientes = Cliente.activos.order(:nombre)
    @productos = Producto.all.order(:nombre)
    @tasas_impuesto = TasaImpuesto.activos.order(:nombre)
  end

  def create
    @factura = Factura.new(factura_params)
    
    ActiveRecord::Base.transaction do
      if @factura.save
        # Crear detalles de factura y validar stock
        params[:detalles]&.each do |detalle|
          next if detalle[:producto_id].blank? || detalle[:cantidad].blank?
          
          producto = Producto.find(detalle[:producto_id])
          cantidad = detalle[:cantidad].to_i
          
          # Validar stock antes de crear el detalle
          unless producto.tiene_stock?(cantidad)
            raise ActiveRecord::Rollback, "No hay suficiente stock para #{producto.nombre}. Stock disponible: #{producto.stock}"
          end
          
          # Crear el detalle
          detalle_factura = @factura.detalle_facturas.create!(
            producto_id: detalle[:producto_id],
            cantidad: cantidad,
            precio_unitario: detalle[:precio_unitario]
          )
          
          # Reducir stock
          producto.reducir_stock(cantidad)
          producto.registrar_salida(cantidad, "Venta", "Factura ##{@factura.numero}", "Usuario")
        end
        
        @factura.calcular_totales
        @factura.save!
        
        redirect_to @factura, notice: 'Factura creada exitosamente.'
      else
        load_form_data
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::Rollback => e
    @factura.errors.add(:base, e.message)
    load_form_data
    render :new, status: :unprocessable_entity
  rescue => e
    @factura.errors.add(:base, e.message)
    load_form_data
    render :new, status: :unprocessable_entity
  end

  private

  def set_factura
    @factura = Factura.find(params[:id])
  end

  def factura_params
    params.require(:factura).permit(:cliente_id, :fecha, :tasa_impuesto_id)
  end
  
  def load_form_data
    @clientes = Cliente.activos.order(:nombre)
    @productos = Producto.all.order(:nombre)
    @tasas_impuesto = TasaImpuesto.activos.order(:nombre)
  end
end
