# encoding: utf-8
class StatsController < ApplicationController
  before_filter :authenticate_user, only: [:mystats, :profstats, :profstats_exam]

  def mystats
    @exams_taken = current_user.exams.where(state: 2)

    @q_taken = @exams_taken.map(&:questions)
    @q_taken = @q_taken.flatten

    q_info = @q_taken.map do |q|
      [q.master_question.language.name.capitalize,
       q.master_question.concept.name.capitalize,
       q.master_question.sub_concept.name.capitalize,
       right_answer?(q)]
    end

    @q_taken_by_language = {}
    for quad in q_info do
      if @q_taken_by_language.key? quad[0]
        if @q_taken_by_language[quad[0]].key? quad[1]
          if @q_taken_by_language[quad[0]][quad[1]].key? quad[2]
            @q_taken_by_language[quad[0]][quad[1]][quad[2]] << quad[3]
          else
            @q_taken_by_language[quad[0]][quad[1]][quad[2]] = [quad[3]]
          end
        else
          @q_taken_by_language[quad[0]][quad[1]] = { quad[2] => [quad[3]] }
        end
      else
        @q_taken_by_language[quad[0]] = { quad[1] => { quad[2] => [quad[3]] } }
      end
    end
  end

  # Returns 1 if question was answered correctly, 0 otherwise
  # private
  def right_answer?(q)
    q.correctAns == q. givenAns ? 1 : 0
  end

  def profstats
    if check_prof
      @exams_agg = {}
      MasterExam.where(user_id: current_user).each do |e|
        actualExams = e.exams
        average = 0
        actualExams.each { |a| average += a.score }
        average /= actualExams.length if actualExams.length > 0

        @exams_agg[e] = [average, actualExams.length, e.users.length]

        # Retroalimentacion de areas
        languagesHashCorrect = {}
        languagesHashIncorrect = {}
        languagesHashIncorrect = {}

        # Se buscan las estadisticas por lenguaje
        Language.all.each do |language|
          puts 'Lenguaje => ' + language.id.to_s

          # Se crean las hash tables con los conceptos del lenguaje para
          # guardar las preguntas correctas e incorrectas
          language.concepts.each do |conceptHash|
            languagesHashCorrect[conceptHash.name] = 0
            languagesHashIncorrect[conceptHash.name] = 0
          end

          puts 'Language correct size = ' + languagesHashCorrect.keys.to_s
          puts 'Language incorrect size = ' + languagesHashIncorrect.keys.to_s

          # Se recorren cada uno de los examenes del usuario actual
          actualExams.each do |exam|
            questions = exam.questions # preguntas del examen
            questions.each do |question|
              correctAns = question.correctAns # respuesta correcta del examen
              givenAns = question.givenAns # respuesta contestada
              masterquestion = question.master_question

              if masterquestion.language.id == language.id
                concept_name = masterquestion.concept.name
                if correctAns == givenAns
                  puts 'Entre respuesta correcta'
                  languagesHashCorrect[concept_name] = languagesHashCorrect[concept_name] + 1
                else
                  languagesHashIncorrect[concept_name] = languagesHashIncorrect[concept_name] + 1
                end
              end
            end
          end

          languagesHashCorrect.each { |key, value| puts "#{key} is #{value}" }
          languagesHashIncorrect.each { |key, value| puts "#{key} is #{value}" }

          languagesHashCorrect.clear
          languagesHashIncorrect.clear
        end
        # Fin Retroalimentacion de areas
      end

      # Information returned is about questions from all professors, in aggregate
      # not only from exams by professor
      @questions_agg = {}
      current_user.master_exams.each do |e|
        e.master_questions.each do |q|
          actualQuestions = q.questions

          if actualQuestions.length > 0
            right = actualQuestions.map { |a| right_answer? a }
            right = right.reduce { |sum, x| sum + x }

            if @questions_agg.key? q
              @questions_agg[q][0] += right
              @questions_agg[q][1] += actualQuestions.length - right
            else
              @questions_agg[q] = [right, actualQuestions.length - right]
            end
          end
        end
      end

    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def profstats_exam
    if check_prof
      @examId = params[:id]
      master_exam = MasterExam.where(user_id: current_user).find(@examId)
      @examName = master_exam.name
      @cantakes = Cantake.where(master_exam_id: master_exam).order(:user_id)
      @h = {}
      @cantakes.each do |c|
        exams_result = []
        @exams =  Exam.where(master_exam_id: master_exam, user_id: c.user)
        @exams.each do |e|
          exams_result.push(e)
        end
        @h[c.user_id] = exams_result
      end
      # Estadisticas para las preguntas de examen por concepto/subconcepto
      @exams_taken = master_exam.exams

      @q_taken = @exams_taken.map(&:questions)
      @q_taken = @q_taken.flatten

      q_info = @q_taken.map do |q|
        master_question = q.master_question
        [master_question.language.name.capitalize,
         master_question.concept.name.capitalize,
         master_question.sub_concept.name.capitalize,
         right_answer?(q)]
      end

      @q_taken_by_language = {}
      q_info.each do |quad|
        if @q_taken_by_language.key? quad[0]
          if @q_taken_by_language[quad[0]].key? quad[1]
            if @q_taken_by_language[quad[0]][quad[1]].key? quad[2]
              @q_taken_by_language[quad[0]][quad[1]][quad[2]] << quad[3]
            else
              @q_taken_by_language[quad[0]][quad[1]][quad[2]] = [quad[3]]
            end
          else
            @q_taken_by_language[quad[0]][quad[1]] = { quad[2] => [quad[3]] }
          end
        else
          @q_taken_by_language[quad[0]] = { quad[1] => { quad[2] => [quad[3]] } }
        end
      end
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def resultadosExamen
    # se crea objeto nuevo

    # id del examen maestro
    @examId = params[:id]
    @examenMaestro = MasterExam.find(@examId)

    @cantakes = Cantake.where(master_exam_id: @examId).order(:user_id)
    @h = {}
    @cantakes.each do |c|
      exams_result = []
      @exams = Exam.where(master_exam_id: @examenMaestro, user_id: c.user)
      @exams.each { |e| exams_result << e }
      @h[c.user_id] = exams_result
    end

    @cantakes.each do |can|
      cont = 1
      @examenes = ExcelFormat.new
      if !@h[can.user_id].empty?
        @h[can.user_id].each do |_h|
          @examenes_anidados = ExcelFormat.new
          @examenes_anidados.usuario =  can.user.username
          @examenes_anidados.intentos = cont
          @examenes_anidados.resultados = @h[can.user_id][cont - 1].score
          @examenes_anidados.save
          cont = cont + 1
        end
     else
       @examenes.usuario = can.user.username
       @examenes.intentos  = 0.0
       @examenes.resultados = 0
       @examenes.save
     end

    end
    @examenest = ExcelFormat.select('usuario ,intentos, resultados').order(:usuario)

    respond_to do |format|
      format.html
      format.csv { send_data @examenest.to_csv }
      format.xls
    end
    ExcelFormat.delete_all
  end
end
