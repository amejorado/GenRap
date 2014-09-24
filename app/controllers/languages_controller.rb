class LanguagesController < ApplicationController
  def index
    @languages = Language.all

    respond_to do |format|
      format.html
      format.json { render json: @languages }
    end
  end

  def show
    @language = Language.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @language }
    end
  end

  def new
    @language = Language.new

    respond_to do |format|
      format.html
      format.json { render json: @language }
    end
  end

  def edit
    @language = Language.find(params[:id])
  end

  def create
    @language = Language.new(params[:language])

    respond_to do |format|
      if @language.save
        format.html { redirect_to @language, notice: 'El lenguaje fue creado de manera exitosa!' }
        format.json { render json: @language, status: :created, location: @language }
      else
        format.html { render action: 'new' }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @language = Language.find(params[:id])

    respond_to do |format|
      if @language.update_attributes(params[:language])
        format.html { redirect_to @language, notice: 'El lenguaje se actualizo de manera exitosa!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @language = Language.find(params[:id])
    @language.destroy
    flash[:notice] = 'El lenguaje fue borrado de manera exitosa!'
    respond_to do |format|
      format.html { redirect_to languages_url }
      format.json { head :no_content }
    end
  end
end
