class TasaImpuestosController < ApplicationController
  before_action :set_tasa_impuesto, only: %i[show edit update destroy]

  def index
    @tasa_impuestos = TasaImpuesto.all.order(:nombre)
  end

  def show
  end

  def new
    @tasa_impuesto = TasaImpuesto.new
  end

  def create
    @tasa_impuesto = TasaImpuesto.new(tasa_impuesto_params)

    if @tasa_impuesto.save
      redirect_to tasa_impuestos_path, notice: "La tasa de impuesto '#{@tasa_impuesto.nombre}' fue creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tasa_impuesto.update(tasa_impuesto_params)
      redirect_to tasa_impuestos_path, notice: "La tasa de impuesto '#{@tasa_impuesto.nombre}' fue actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    nombre_tasa = @tasa_impuesto.nombre
    
    if !@tasa_impuesto.puede_ser_eliminado?
      redirect_to tasa_impuestos_url, alert: "No se puede eliminar la tasa '#{nombre_tasa}' porque está siendo utilizada por facturas existentes."
    elsif @tasa_impuesto.destroy
      redirect_to tasa_impuestos_url, notice: "La tasa de impuesto '#{nombre_tasa}' fue eliminada exitosamente."
    else
      redirect_to tasa_impuestos_url, alert: "Ocurrió un error al eliminar la tasa de impuesto '#{nombre_tasa}'."
    end
  end

  private

  def set_tasa_impuesto
    @tasa_impuesto = TasaImpuesto.find(params[:id])
  end

  def tasa_impuesto_params
    params.require(:tasa_impuesto).permit(:nombre, :porcentaje, :descripcion, :activo, :predeterminado)
  end
end
