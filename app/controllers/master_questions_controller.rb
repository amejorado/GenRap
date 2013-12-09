  #encoding: utf-8
class MasterQuestionsController < ApplicationController
  $randomizer = ''
  $solver = ''
  @inquiriesMasterQuestionsIDs = {}

  before_filter :authenticate_user, :only => [:new, :index, :create,:show, :edit, :update, :destroy, :backup]
  # Create actions
  def new
    #if check_admin || check_prof
    if check_admin
      if @master_question == nil
        @master_question = MasterQuestion.new
        @master_question.randomizer = initialize_file('randomizer')
        @master_question.solver = initialize_file('solver')
        @master_question.inquiry = initialize_file('inquiry')
      else
        @master_question = params[:object]
      end
    else
      flash[:error] = "Acceso restringido."
      redirect_to(root_path)
    end
  end

  def backup

    $file_name = "Questions_backup"
	prebackup_file = File.dirname(__FILE__) + "/../../#{$file_name}.txt"
	File.open(File.dirname(__FILE__) + "/../../#{$file_name}.txt", "w"){ |somefile| somefile.puts "
			Reslpaldo de MasterQuestions "}
	separator = "\r\n **************** \r\n"
	blankspace = "\r\n\r\n"
	file_error = false

    MasterQuestion.all.each do |mq|
		inquiry = mq.inquiry
		$randomizer = mq.randomizer
        $solver = mq.solver

        # Retrieve code from files
        crandomizer = read_file(File.dirname(__FILE__) + "/../helpers/r/#{$randomizer}.rb")
        csolver = read_file(File.dirname(__FILE__) + "/../helpers/s/#{$solver}.rb")

		File.open(prebackup_file,"a+") do |outfile| 
			outfile << inquiry 
			outfile << blankspace
			outfile << csolver
			outfile << blankspace
			outfile << crandomizer
			outfile << blankspace
			outfile << blankspace
			outfile << separator
			outfile << blankspace
		end
	end
	
	@masterSelections = MasterQuestion.all(:order => "language_id ASC", :group => "language_id")
	@masterQuestions = MasterQuestion.all
	
	flash[:notice] = "Backup realizado exitosamente."
    redirect_to(master_questions_path)

  end

  def create
    #if check_prof || check_admin
    if check_admin
      params[:master_question][:borrado] = 0
      @master_question = MasterQuestion.new(params[:master_question], :without_protection => true)

      # Generate random name for solver and randomizer
      uuid = SecureRandom.uuid
      #$randomizer = "#{uuid}_randomizer"
      #$solver = "#{uuid}_solver"
      randomizer = "#{uuid}_randomizer"
      solver = "#{uuid}_solver"

      # Create solver and randomizer files in /helpers/s and /helpers/r
      #rand_file = File.dirname(__FILE__) + "/../helpers/r/#{$randomizer}.rb"
      #solv_file = File.dirname(__FILE__) + "/../helpers/s/#{$solver}.rb"
      rand_file = File.dirname(__FILE__) + "/../helpers/r/#{randomizer}.rb"
      solv_file = File.dirname(__FILE__) + "/../helpers/s/#{solver}.rb"

      randomizer_file = File.open(rand_file,"w") {|f| f.write("#{@master_question.randomizer}") }
      solver_file = File.open(solv_file,"w") {|f| f.write("#{@master_question.solver}")}

      rand_file_error = false
      solv_file_error = false


      # Verficicar error en el randomizer
      begin
        load rand_file
      rescue Exception => exc
        rand_file_error = true
      end

      # Verificar error en el solver
      begin
        load solv_file
      rescue Exception => exc
        solv_file_error = true
      end

      # Notificar del error
      if solv_file_error && rand_file_error
        flash[:error] = "Error al ejecutar randomizer y solver, por favor revise su código."
        render :action => "new" and return
      elsif solv_file_error
        flash[:error] = "Error al ejecutar solver, por favor revise su código."
        render :action => "new" and return
      elsif rand_file_error
        flash[:error] = "Error al ejecutar randomizer, por favor revise su código."
        render :action => "new" and return
      end


      # Save masterquestion solver and randomizer file path
      #@master_question.randomizer = "#{$randomizer}"
      #@master_question.solver = "#{$solver}"
      @master_question.randomizer = "#{randomizer}"
      @master_question.solver = "#{solver}"

      if @master_question.save
        flash[:notice] = "MasterQuestion creada exitosamente."
      else
        flash[:error] = "Los datos proporcionados no son válidos."
      end
      redirect_to(master_questions_path)
    else
      flash[:error] = "Acceso restringido."
      redirect_to root_path
    end
  end

  # Read actions
  def index
    if check_prof || check_admin
      if(params[:id])
        @masterQuestions = MasterQuestion.find(:all,:conditions => ["master_questions.language_id = ?",params[:id]],:joins => :concept,:order => ["language_id","concepts.name"])
	  else
        @masterQuestions = MasterQuestion.find(:all,:joins => :concept,:order => ["language_id","concepts.name"])
      end
      @masterSelections = MasterQuestion.select("DISTINCT language_id").where("borrado = 0").order("language_id")
    else
      flash[:error] = "Acceso restringido."
      redirect_to(root_path)
    end
  end

  def show
    if check_prof || check_admin
      @master_question = MasterQuestion.find(params[:id],:joins => :concept,:order => ["concepts.name"])

      # Get files path
      $randomizer = @master_question.randomizer
      $solver = @master_question.solver

      # Retrieve code from files
      @master_question.randomizer = read_file(File.dirname(__FILE__) + "/../helpers/r/#{$randomizer}.rb")
      @master_question.solver = read_file(File.dirname(__FILE__) + "/../helpers/s/#{$solver}.rb")
    else
      flash[:error] = "Acceso restringido."
      redirect_to(root_path)
    end
  end

  #Update actions
  def edit
    #if check_prof || check_admin
    if check_admin
      @master_question = MasterQuestion.find(params[:id])
      #$randomizer = @master_question.randomizer
      #$solver = @master_question.solver

      randomizer = @master_question.randomizer
      solver = @master_question.solver

      # Retrieve code from files
      #@master_question.randomizer = read_file(File.dirname(__FILE__) + "/../helpers/r/#{$randomizer}.rb")
      #@master_question.solver = read_file(File.dirname(__FILE__) + "/../helpers/s/#{$solver}.rb")
      @master_question.randomizer = read_file(File.dirname(__FILE__) + "/../helpers/r/#{randomizer}.rb")
      @master_question.solver = read_file(File.dirname(__FILE__) + "/../helpers/s/#{solver}.rb")
    else
      flash[:error] = "Acceso restringido."
      redirect_to(root_path)
    end
  end

  def update
    #if check_prof || check_admin
    if check_admin
      @master_question = MasterQuestion.find(params[:id])

      randomizer = @master_question.randomizer
      solver = @master_question.solver

      # Create master temporal
      master_temporal =  MasterQuestion.new(params[:master_question], :without_protection => true)

      # Saves code to randomizer and solver files
      #File.open(File.dirname(__FILE__) + "/../helpers/r/#{$randomizer}.rb","w") {|f| f.write("#{master_temporal.randomizer}")}
      #File.open(File.dirname(__FILE__) + "/../helpers/s/#{$solver}.rb","w") {|f| f.write("#{master_temporal.solver}")}
      File.open(File.dirname(__FILE__) + "/../helpers/r/#{randomizer}.rb","w") {|f| f.write("#{master_temporal.randomizer}")}
      File.open(File.dirname(__FILE__) + "/../helpers/s/#{solver}.rb","w") {|f| f.write("#{master_temporal.solver}")}

      # Updates randomizer and solver fields
      #master_temporal.randomizer = $randomizer
      #master_temporal.solver = $solver
      master_temporal.randomizer = randomizer
      master_temporal.solver = solver

      if @master_question.update_attributes(:language_id => master_temporal.language_id, :concept_id => master_temporal.concept_id, :subconcept_id => master_temporal.subconcept_id,
                                         :inquiry => master_temporal.inquiry, :randomizer => master_temporal.randomizer, :solver => master_temporal.solver)
        flash[:notice] = 'La pregunta maestra fue actualizada de manera correcta.'
      else
        flash[:error] = 'No se pudieron actualizar los datos de la pregunta maestra.'
      end

      redirect_to(@master_question)
    else
      flash[:error] = "Acceso restringido."
     redirect_to(root_path)
    end
  end

  # Read file from file_path

  def read_file (file_path)
    @code = ''
    File.open(file_path,'r') do |file|
      while line = file.gets
        @code << line
      end
    end
    @code
  end

  # Write initialize file
  def initialize_file filename
    text = ''
    case filename
    when 'randomizer'
      text << "def randomize(inquiry)\n  values = Hash.new('')\n" +
              "  #Inserte su codigo para llenar values aqui\n" +
              "  values['^1'] = Random.rand(1..2)\n  values['^2'] = Random.rand(5..10)\n" +
              "  values\nend"
    when 'solver'
      text << "def solve(inquiry, values)\n  answers = Hash.new('')\n" +
              "  #Inserte su codigo para llenar generar answers aqui\n" +
              "  answers[1] = values['^1'] + values['^2']\n  answers[2] = values['^1'] - values['^2']\n" +
              "  #Inserte su codigo para indicar la respuesta correcta\n" +
              "  correct = 1\n [answers, correct]\nend\n\n"
    when 'inquiry'
      text << "¿Cuánto es ^1 + ^2?"
    end
    text
  end

  # Delete actions
  def destroy
    #if check_prof || check_admin
    if check_admin
      @master_question = MasterQuestion.find(params[:id])

      # Delete randomizer and solver files
      if File.exists?(@master_question.randomizer)
        File.delete(@master_question.randomizer)
      end

      if File.exists?(@master_question.solver)
        File.delete(@master_question.solver)
      end

      @master_question.destroy

      redirect_to :action => 'index'
    else
      flash[:error] = "Acceso restringido."
      redirect_to(master_questions_path)
    end
  end

  def concepts_for_question
    # Get concepts filtered by language
    concepts = Concept.find(:all,:conditions => ["concepts.language_id = ?","#{params[:language]}"],:include => "master_questions",:group  => 'master_questions.id HAVING COUNT(master_questions.id) >= 1')
    respond_to do |format|
      format.json { render json: concepts.to_json }
    end
  end

  def subconcepts_for_question
    # Get subconcepts filtered by parent concept

	  subconcepts = SubConcept.select("name, id").where("concept_id = '#{params[:concept]}'")
    respond_to do |format|
      format.json { render json: subconcepts.to_json }
    
    end
  end

  def filtered_master_questions
    # Get master questions based on the language, concept and subconcept
    filteredMQs = MasterQuestion.select("inquiry, id").where("language_id = '#{params[:language]}'").where("concept_id = '#{params[:concept]}'").where("subconcept_id = '#{params[:subconcept]}'").where("borrado = 0")
    respond_to do |format|
      format.json { render json: filteredMQs.to_json }
    end
  end

  def transmiting_JSON
    @inquiriesMasterQuestionsIDs = Array.new
    @inquiriesMasterQuestionsIDs.push params[:masterQuestionID]
    respond_to do |format|
      format.json { render json: @inquiriesMasterQuestionsIDs.to_json }
    end
  end

  def get_languages
    languages = Language.select("id, name");
    respond_to do |format|
      format.json { render json: languages.to_json }
    end
  end



  def deleteQuestion
    #if check_prof || check_admin
    if check_admin
      @master_question = MasterQuestion.find(params[:id])
      if @master_question.update_attributes(:borrado => "1", :questionDateDeleted => Time.now)
        flash[:notice] = 'La pregunta maestra fue borrada de manera correcta.'
      else
        flash[:error] = 'No se pudieron actualizar los datos de la pregunta maestra.'
      end
      redirect_to :controller => 'master_questions', :action => 'index'
    else
      #flash[:error] = "Acceso restringido."
    end
  end

  def deleted_questions
    #if check_prof || check_admin
    if check_admin
     @master_question = MasterQuestion.where("borrado = '1'")
    else
      flash[:error] = "Acceso restringido."
      redirect_to(root_path)
    end
  end
end
