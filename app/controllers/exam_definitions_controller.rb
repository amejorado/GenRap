class ExamDefinitionsController < ApplicationController
  # GET /exam_definitions
  # GET /exam_definitions.json
  def index
    @exam_definitions = ExamDefinition.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @exam_definitions }
    end
  end

  # GET /exam_definitions/1
  # GET /exam_definitions/1.json
  def show
    @exam_definition = ExamDefinition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @exam_definition }
    end
  end

  # GET /exam_definitions/new
  # GET /exam_definitions/new.json
  def new
    @exam_definition = ExamDefinition.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @exam_definition }
    end
  end

  # GET /exam_definitions/1/edit
  def edit
    @exam_definition = ExamDefinition.find(params[:id])
  end

  # POST /exam_definitions
  # POST /exam_definitions.json
  def create
    @exam_definition = ExamDefinition.new(params[:exam_definition])

    respond_to do |format|
      if @exam_definition.save
        format.html { redirect_to @exam_definition, notice: 'Exam definition was successfully created.' }
        format.json { render json: @exam_definition, status: :created, location: @exam_definition }
      else
        format.html { render action: "new" }
        format.json { render json: @exam_definition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /exam_definitions/1
  # PUT /exam_definitions/1.json
  def update
    @exam_definition = ExamDefinition.find(params[:id])

    respond_to do |format|
      if @exam_definition.update_attributes(params[:exam_definition])
        format.html { redirect_to @exam_definition, notice: 'Exam definition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @exam_definition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /exam_definitions/1
  # DELETE /exam_definitions/1.json
  def destroy
    @exam_definition = ExamDefinition.find(params[:id])
    @exam_definition.destroy

    respond_to do |format|
      format.html { redirect_to exam_definitions_url }
      format.json { head :no_content }
    end
  end
end
