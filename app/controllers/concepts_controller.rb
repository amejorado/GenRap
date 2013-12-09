class ConceptsController < ApplicationController
  # GET /concepts
  # GET /concepts.json
  before_filter :authenticate_admin, :only => [:new, :index, :create,:show, :edit, :update, :destroy]

  def index
    @concepts = Concept.all(:order => "language_id ASC")


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @concepts }
    end
  end

  # GET /concepts/1
  # GET /concepts/1.json
  def show
    @concept = Concept.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @concept }
    end
  end

  # GET /concepts/new
  # GET /concepts/new.json
  def new
    @concept = Concept.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @concept }
    end
  end

  # GET /concepts/1/edit
  def edit
    @concept = Concept.find(params[:id])
  end

  # POST /concepts
  # POST /concepts.json
  def create
    @concept = Concept.new(params[:concept])

    respond_to do |format|
      if @concept.save
        format.html { redirect_to @concept, notice: 'El concepto fue creado de manera exitosa!' }
        format.json { render json: @concept, status: :created, location: @concept }
      else
        format.html { render action: "new" }
        format.json { render json: @concept.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /concepts/1
  # PUT /concepts/1.json
  def update
    @concept = Concept.find(params[:id])

    respond_to do |format|
      if @concept.update_attributes(params[:concept])
        format.html { redirect_to @concept, notice: 'El concepto fue actualizado de manera exitosa!' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @concept.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /concepts/1
  # DELETE /concepts/1.json
  def destroy
    @concept = Concept.find(params[:id])
    @sub_concepts = @concept.sub_concepts
    @sub_concepts.each do |sc|
      sc.destroy
    end
    @concept.destroy
    flash[:notice] = 'El concepto fue borrado de manera exitosa!'

    respond_to do |format|
      format.html { redirect_to concepts_url }
      format.json { head :no_content }
    end
  end
end
