class MovimientoStocksController < ApplicationController
  before_action :set_movimiento_stock, only: [:show]
  before_action :set_producto, only: [:new, :create]
  
  def index
    @movimientos = MovimientoStock.includes(:producto).recientes
    
    # Filtros
    if params[:producto_id].present?
      @movimientos = @movimientos.por_producto(params[:producto_id])
    end
    
    if params[:tipo_movimiento].present?
      @movimientos = @movimientos.where(tipo_movimiento: params[:tipo_movimiento])
    end
    
    if params[:fecha_inicio].present? && params[:fecha_fin].present?
      @movimientos = @movimientos.por_fecha(params[:fecha_inicio], params[:fecha_fin])
    end
    
    # Paginación opcional (si Kaminari está disponible)
    if defined?(Kaminari) && @movimientos.respond_to?(:page)
      @movimientos = @movimientos.page(params[:page]).per(20)
    else
      @movimientos = @movimientos.limit(20)
    end
    
    @productos = Producto.all.order(:nombre)
  end
  
  def show
  end
  
  def new
    @movimiento_stock = MovimientoStock.new
    @tipos_movimiento = [
      ['Entrada de Stock', 'entrada'],
      ['Salida de Stock', 'salida'],
      ['Ajuste de Inventario', 'ajuste']
    ]
  end
  
  def create
    begin
      @movimiento_stock = MovimientoStock.registrar_movimiento(
        @producto,
        movimiento_params[:tipo_movimiento],
        movimiento_params[:cantidad].to_i,
        movimiento_params[:motivo],
        movimiento_params[:observaciones],
        movimiento_params[:usuario] || 'Usuario'
      )
      
      redirect_to movimiento_stocks_path, notice: 'Movimiento de stock registrado exitosamente.'
    rescue => e
      @movimiento_stock = MovimientoStock.new(movimiento_params)
      @tipos_movimiento = [
        ['Entrada de Stock', 'entrada'],
        ['Salida de Stock', 'salida'],
        ['Ajuste de Inventario', 'ajuste']
      ]
      flash.now[:alert] = "Error al registrar movimiento: #{e.message}"
      render :new
    end
  end
  
  def motivos
    tipo = params[:tipo]
    motivos = MovimientoStock.motivos_por_tipo(tipo)
    render json: motivos
  end
  
  def historial_producto
    @producto = Producto.find(params[:producto_id])
    @movimientos = @producto.movimiento_stocks.recientes
    
    # Paginación opcional (si Kaminari está disponible)
    if defined?(Kaminari) && @movimientos.respond_to?(:page)
      @movimientos = @movimientos.page(params[:page]).per(10)
    else
      @movimientos = @movimientos.limit(10)
    end
    
    render layout: false if request.xhr?
  end
  
  private
  
  def set_movimiento_stock
    @movimiento_stock = MovimientoStock.find(params[:id])
  end
  
  def set_producto
    @producto = Producto.find(params[:producto_id]) if params[:producto_id].present?
  end
  
  def movimiento_params
    params.require(:movimiento_stock).permit(:tipo_movimiento, :cantidad, :motivo, :observaciones, :usuario)
  end
end
