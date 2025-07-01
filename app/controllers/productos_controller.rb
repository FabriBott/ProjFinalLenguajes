class ProductosController < ApplicationController
  before_action :set_producto, only: [:show, :edit, :update, :destroy]

  def index
    @productos = Producto.all
  end

  def show
  end

  def new
    @producto = Producto.new
  end

  def create
    @producto = Producto.new(producto_params)
    if @producto.save
      redirect_to productos_path, notice: "El producto '#{@producto.nombre}' fue creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      stock_anterior = @producto.stock
      
      if @producto.update(producto_params)
        # Registrar motivo del cambio de stock si el stock ha cambiado
        if @producto.saved_change_to_stock?
          motivo = params[:motivo_stock].presence || 'Cambio manual'
          observaciones = params[:observaciones_stock]
          usuario = params[:usuario_stock].presence || 'Usuario'
          
          # Determinar el tipo de movimiento basado en el cambio
          stock_nuevo = @producto.stock
          if stock_nuevo > stock_anterior
            tipo_movimiento = 'entrada'
            cantidad = stock_nuevo - stock_anterior
          elsif stock_nuevo < stock_anterior
            tipo_movimiento = 'salida'
            cantidad = stock_anterior - stock_nuevo
          else
            tipo_movimiento = 'ajuste'
            cantidad = stock_nuevo
          end
          
          # Crear el movimiento usando el método registrar_movimiento pero con el stock anterior correcto
          MovimientoStock.create!(
            producto: @producto,
            tipo_movimiento: tipo_movimiento,
            cantidad: cantidad,
            cantidad_anterior: stock_anterior,
            cantidad_nueva: stock_nuevo,
            motivo: motivo,
            observaciones: observaciones,
            usuario: usuario,
            fecha_movimiento: Time.current
          )
        end
        
        redirect_to productos_path, notice: "El producto '#{@producto.nombre}' fue actualizado exitosamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  rescue => e
    flash.now[:alert] = "Error al actualizar el producto: #{e.message}"
    render :edit, status: :unprocessable_entity
  end

  def destroy
    nombre_producto = @producto.nombre
    @producto.destroy
    redirect_to productos_path, notice: "El producto '#{nombre_producto}' fue eliminado exitosamente."
  end

  private

  def set_producto
    @producto = Producto.find(params[:id])
  end

  def producto_params
    params.require(:producto).permit(:nombre, :precio, :stock)
  end
end
