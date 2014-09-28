class ConceptsController < ApplicationController
  def index
    @concepts = Concept.order(:language_id)

    respond_to do |format|
      format.html
      format.json { render json: @concepts }
    end
  end

  def show
    @concept = Concept.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @concept }
    end
  end

  def new
    @concept = Concept.new

    respond_to do |format|
      format.html
      format.json { render json: @concept }
    end
  end

  def edit
    @concept = Concept.find(params[:id])
  end

  def create
    @concept = Concept.new(params[:concept])

    respond_to do |format|
      if @concept.save
        format.html { redirect_to @concept, notice: 'El concepto fue creado de manera exitosa!' }
        format.json { render json: @concept, status: :created, location: @concept }
      else
        format.html { render action: 'new' }
        format.json { render json: @concept.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @concept = Concept.find(params[:id])

    respond_to do |format|
      if @concept.update_attributes(params[:concept])
        format.html { redirect_to @concept, notice: 'El concepto fue actualizado de manera exitosa!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @concept.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @concept = Concept.find(params[:id])
    @concept.destroy
    flash[:notice] = 'El concepto fue borrado de manera exitosa!'

    respond_to do |format|
      format.html { redirect_to concepts_url }
      format.json { head :no_content }
    end
  end
end
