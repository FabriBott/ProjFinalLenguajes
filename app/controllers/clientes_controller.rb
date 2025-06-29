class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :edit, :update, :destroy, :toggle_estado]

  def index
    @clientes_activos = Cliente.activos.order(:nombre)
    @clientes_inactivos = Cliente.inactivos.order(:nombre)
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
    Rails.logger.info "=== DESTROY METHOD CALLED ==="
    Rails.logger.info "Cliente ID: #{@cliente.id}"
    Rails.logger.info "Puede ser eliminado: #{@cliente.puede_ser_eliminado?}"
    Rails.logger.info "Facturas count: #{@cliente.facturas.count}"
    
    if @cliente.puede_ser_eliminado?
      @cliente.destroy
      redirect_to clientes_url, notice: 'Cliente eliminado exitosamente.'
    else
      redirect_to clientes_url, alert: 'No se puede eliminar el cliente porque tiene facturas asociadas. Use "Desactivar" en su lugar.'
    end
  end

  def toggle_estado
    if @cliente.activo?
      @cliente.desactivar!
      redirect_to @cliente, notice: 'Cliente desactivado exitosamente.'
    else
      @cliente.activar!
      redirect_to @cliente, notice: 'Cliente activado exitosamente.'
    end
  end

  private

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(:nombre, :cedula, :email, :telefono, :direccion)
  end
end
