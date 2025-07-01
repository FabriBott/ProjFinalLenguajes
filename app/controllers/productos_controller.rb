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
    if @producto.update(producto_params)
      redirect_to productos_path, notice: "El producto '#{@producto.nombre}' fue actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
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
