class SubConceptsController < ApplicationController
  def index
    @sub_concepts = SubConcept.all

    respond_to do |format|
      format.html
      format.json { render json: @sub_concepts }
    end
  end

  def show
    @sub_concept = SubConcept.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @sub_concept }
    end
  end

  def new
    @sub_concept = SubConcept.new

    respond_to do |format|
      format.html
      format.json { render json: @sub_concept }
    end
  end

  def edit
    @sub_concept = SubConcept.find(params[:id])
  end

  def create
    @sub_concept = SubConcept.new(params[:sub_concept])

    respond_to do |format|
      if @sub_concept.save
        format.html { redirect_to @sub_concept, notice: 'El subconcepto fue creado de manera exitosa!' }
        format.json { render json: @sub_concept, status: :created, location: @sub_concept }
      else
        format.html { render action: 'new' }
        format.json { render json: @sub_concept.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @sub_concept = SubConcept.find(params[:id])

    respond_to do |format|
      if @sub_concept.update_attributes(params[:sub_concept])
        format.html { redirect_to @sub_concept, notice: 'El subconcepto fue actualizado de manera exitosa!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sub_concept.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sub_concept = SubConcept.find(params[:id])
    @sub_concept.destroy
    flash[:notice] = 'El subconcepto fue borrado de manera exitosa!'
    respond_to do |format|
      format.html { redirect_to sub_concepts_url }
      format.json { head :no_content }
    end
  end
end
