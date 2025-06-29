class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :edit, :update, :destroy]

  def index
    @clientes = Cliente.all.order(:nombre)
  end

  def show
  end

  def new
    @cliente = Cliente.new
  end

  def create
    @cliente = Cliente.new(cliente_params)
    
    if @cliente.save
      redirect_to @cliente, notice: 'Cliente creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cliente.update(cliente_params)
      redirect_to @cliente, notice: 'Cliente actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cliente.destroy
    redirect_to clientes_url, notice: 'Cliente eliminado exitosamente.'
  end

  private

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(:nombre, :cedula, :email, :telefono, :direccion)
  end
end
