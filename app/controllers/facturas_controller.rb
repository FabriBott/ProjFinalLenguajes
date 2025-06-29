class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :pdf]

  def index
    @facturas = Factura.includes(:cliente).por_fecha
  end

  def show
  end

  def new
    @factura = Factura.new
    @clientes = Cliente.all.order(:nombre)
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
      @clientes = Cliente.all.order(:nombre)
      @productos = Producto.all.order(:nombre)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @clientes = Cliente.all.order(:nombre)
    @productos = Producto.all.order(:nombre)
  end

  def update
    if @factura.update(factura_params)
      redirect_to @factura, notice: 'Factura actualizada exitosamente.'
    else
      @clientes = Cliente.all.order(:nombre)
      @productos = Producto.all.order(:nombre)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @factura.destroy
    redirect_to facturas_url, notice: 'Factura eliminada exitosamente.'
  end

  def pdf
    respond_to do |format|
      format.pdf do
        pdf = FacturaPdf.new(@factura)
        send_data pdf.render, 
                  filename: "factura_#{@factura.numero}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
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
