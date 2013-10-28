class SubConceptsController < ApplicationController
  # GET /sub_concepts
  # GET /sub_concepts.json
  def index
    @sub_concepts = SubConcept.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sub_concepts }
    end
  end

  # GET /sub_concepts/1
  # GET /sub_concepts/1.json
  def show
    @sub_concept = SubConcept.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sub_concept }
    end
  end

  # GET /sub_concepts/new
  # GET /sub_concepts/new.json
  def new
    @sub_concept = SubConcept.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sub_concept }
    end
  end

  # GET /sub_concepts/1/edit
  def edit
    @sub_concept = SubConcept.find(params[:id])
  end

  # POST /sub_concepts
  # POST /sub_concepts.json
  def create
    @sub_concept = SubConcept.new(params[:sub_concept])

    respond_to do |format|
      if @sub_concept.save
        format.html { redirect_to @sub_concept, notice: 'Sub concept was successfully created.' }
        format.json { render json: @sub_concept, status: :created, location: @sub_concept }
      else
        format.html { render action: "new" }
        format.json { render json: @sub_concept.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sub_concepts/1
  # PUT /sub_concepts/1.json
  def update
    @sub_concept = SubConcept.find(params[:id])

    respond_to do |format|
      if @sub_concept.update_attributes(params[:sub_concept])
        format.html { redirect_to @sub_concept, notice: 'Sub concept was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sub_concept.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sub_concepts/1
  # DELETE /sub_concepts/1.json
  def destroy
    @sub_concept = SubConcept.find(params[:id])
    @sub_concept.destroy

    respond_to do |format|
      format.html { redirect_to sub_concepts_url }
      format.json { head :no_content }
    end
  end
end
