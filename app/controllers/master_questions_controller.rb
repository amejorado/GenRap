# encoding: utf-8
class MasterQuestionsController < ApplicationController
  @inquiriesMasterQuestionsIDs = {}

  def new
    if @master_question
      @master_question = params[:object]
    else
      @master_question = MasterQuestion.new
      @master_question.randomizer = initialize_file('randomizer')
      @master_question.solver = initialize_file('solver')
      @master_question.inquiry = initialize_file('inquiry')
    end
  end

  def backup
    file_name = 'Questions_backup'
    prebackup_file = File.dirname(__FILE__) + "/../../#{file_name}.txt"
    File.open(File.dirname(__FILE__) + "/../../#{file_name}.txt", 'w') do |somefile|
      somefile.puts "
         Reslpaldo de MasterQuestions "
    end
    separator = "\r\n **************** \r\n"
    blankspace = "\r\n\r\n"
    file_error = false

    MasterQuestion.all.each do |mq|
      inquiry = mq.inquiry
      crandomizer = mq.randomizer
      csolver = mq.solver

      File.open(prebackup_file, 'a+') do |outfile|
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

    @masterSelections = MasterQuestion.order('language_id ASC').group('language_id')
    @masterQuestions = MasterQuestion.all
    flash[:notice] = 'Backup realizado exitosamente.'
    redirect_to master_questions_path
  end

  def create
    params[:master_question][:borrado] = 0
    @master_question = MasterQuestion.new(params[:master_question])

    if @master_question.save
      flash[:notice] = 'MasterQuestion creada exitosamente.'
      redirect_to master_questions_path
    else
      flash[:error] = 'Los datos proporcionados no son válidos.'
      render :new
    end
  end

  # Read actions
  def index
    if params[:id]
      @masterQuestions = MasterQuestion
        .find(:all,
              conditions: ['master_questions.language_id = ?', params[:id]],
              joins: :concept, order: ['language_id', 'concepts.name'])
    else
      @masterQuestions = MasterQuestion.find(:all, joins: :concept, order: ['language_id', 'concepts.name'])
    end
    @masterSelections = MasterQuestion.select('DISTINCT language_id').where('borrado = 0').order('language_id')
  end

  def show
    @master_question = MasterQuestion.find(params[:id], joins: :concept, order: ['concepts.name'])
  end

  # Update actions
  def edit
    @master_question = MasterQuestion.find(params[:id])
  end

  def update
    @master_question = MasterQuestion.find(params[:id])

    if @master_question.update_attributes(params[:master_question])
      flash[:notice] = 'La pregunta maestra fue actualizada de manera correcta.'
    else
      flash[:error] = 'No se pudieron actualizar los datos de la pregunta maestra.'
    end

    redirect_to(@master_question)
  end

  # Write initialize file
  def initialize_file(filename)
    text = ''
    case filename
    when 'randomizer'
      text << "def randomize(inquiry)\n  values = Hash.new('')\n" \
              "  #Inserte su codigo para llenar values aqui\n" \
              "  values['^1'] = Random.rand(1..2)\n  values['^2'] = Random.rand(5..10)\n" \
              "  values\nend"
    when 'solver'
      text << "def solve(inquiry, values)\n  answers = Hash.new('')\n" \
              "  #Inserte su codigo para llenar generar answers aqui\n" \
              "  answers[1] = values['^1'] + values['^2']\n  answers[2] = values['^1'] - values['^2']\n" \
              "  #Inserte su codigo para indicar la respuesta correcta\n" \
              "  correct = 1\n [answers, correct]\nend\n\n"
    when 'inquiry'
      text << '¿Cuánto es ^1 + ^2?'
    end
    text
  end

  # Delete actions
  def destroy
    @master_question = MasterQuestion.find(params[:id])
    @master_question.destroy
    redirect_to action: 'index'
  end

  def concepts_for_question
    # Get concepts filtered by language
    concepts = Concept.find(:all, conditions: ['concepts.language_id = ?', "#{params[:language]}"])
    respond_to do |format|
      format.json { render json: concepts.to_json }
    end
  end

  def subconcepts_for_question
    # Get subconcepts filtered by parent concept

    subconcepts = SubConcept.find_by_sql('SELECT DISTINCT "sub_concepts"."id", "sub_concepts"."name", "sub_concepts"."concept_id" FROM "sub_concepts" LEFT JOIN "master_questions" ON "master_questions"."subconcept_id" = "sub_concepts"."id" WHERE (sub_concepts.concept_id = ' + params[:concept] + ')')

    respond_to do |format|
      format.json { render json: subconcepts.to_json }
    end
  end

  def filtered_master_questions
    # Get master questions based on the language, concept and subconcept
    filteredMQs = MasterQuestion.select('inquiry, id')
      .where(language_id: params[:language], concept_id: params[:concept],
             subconcept_id: params[:subconcept], borrado: '0')
    respond_to do |format|
      format.json { render json: filteredMQs.to_json }
    end
  end

  def transmiting_JSON
    @inquiriesMasterQuestionsIDs = [params[:masterQuestionID]]
    respond_to do |format|
      format.json { render json: @inquiriesMasterQuestionsIDs.to_json }
    end
  end

  def get_languages
    languages = Language.select('id, name')
    respond_to do |format|
      format.json { render json: languages.to_json }
    end
  end

  def deleteQuestion
    @master_question = MasterQuestion.find(params[:id])
    if @master_question.update_attributes(borrado: '1',
                                          questionDateDeleted: Time.zone.now)
      flash[:notice] = 'La pregunta maestra fue borrada de manera correcta.'
    else
      flash[:error] = 'No se pudieron actualizar los datos de la pregunta maestra.'
    end
    redirect_to controller: 'master_questions', action: 'index'
  end

  def deleted_questions
    @master_question = MasterQuestion.where(borrado: '1')
  end
end
