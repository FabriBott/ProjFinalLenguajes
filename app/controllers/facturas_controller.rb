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
  end

  def create
    @factura = Factura.new(factura_params)
    
    if @factura.save
      # Crear detalles de factura
      params[:detalles]&.each do |detalle|
        next if detalle[:producto_id].blank? || detalle[:cantidad].blank?
        
        @factura.detalle_facturas.create!(
          producto_id: detalle[:producto_id],
          cantidad: detalle[:cantidad],
          precio_unitario: detalle[:precio_unitario]
        )
      end
      
      @factura.calcular_totales
      @factura.save!
      
      redirect_to @factura, notice: 'Factura creada exitosamente.'
    else
      @clientes = Cliente.activos.order(:nombre)
      @productos = Producto.all.order(:nombre)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_factura
    @factura = Factura.find(params[:id])
  end

  def factura_params
    params.require(:factura).permit(:cliente_id, :fecha)
  end
end
