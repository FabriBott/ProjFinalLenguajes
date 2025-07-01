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
      redirect_to @tasa_impuesto, notice: 'Tasa de impuesto creada exitosamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @tasa_impuesto.update(tasa_impuesto_params)
      redirect_to @tasa_impuesto, notice: 'Tasa de impuesto actualizada exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    if @tasa_impuesto.puede_ser_eliminado? && @tasa_impuesto.destroy
      redirect_to tasa_impuestos_url, notice: 'Tasa de impuesto eliminada exitosamente.'
    else
      redirect_to tasa_impuestos_url, alert: 'No se puede eliminar la tasa de impuesto.'
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
