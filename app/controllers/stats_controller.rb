# encoding: utf-8
class StatsController < ApplicationController
  before_filter :authenticate_user, only: [:mystats, :profstats, :profstats_exam]

  def mystats
    @exams_taken = @current_user.exams.where(state: 2)

    @q_taken = @exams_taken.map { |e| e.questions }
    @q_taken = @q_taken.flatten

    q_info = @q_taken.map { |q| [MasterQuestion.find(q.master_question_id).language.name.capitalize, MasterQuestion.find(q.master_question_id).concept.name.capitalize, MasterQuestion.find(q.master_question_id).sub_concept.name.capitalize, right_answer?(q)] }

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
    if q.correctAns == q. givenAns
      return 1
    else
      return 0
    end
  end

  def profstats
    if check_prof
      @exams_agg = {}
      for e in MasterExam.where('user_id = ?', @current_user.id) do
        actualExams = e.exams
        average = 0
        for a in actualExams do
          average += a.score
        end
        if actualExams.length > 0
          average /= actualExams.length
        end

        @exams_agg[e] = [average, actualExams.length, e.users.length]

        # Retroalimentacion de areas
        languagesHashCorrect = {}
        languagesHashIncorrect = {}
        languagesHashIncorrect = {}

        # Se buscan las estadisticas por lenguaje
        for language in Language.select(:id) do
          puts 'Lenguaje => ' + language.id.to_s

          # Se crean las hash tables con los conceptos del lenguaje para
          # guardar las preguntas correctas e incorrectas
          for conceptHash in Concept.where('language_id = ?', language.id) do
            languagesHashCorrect[conceptHash.name] = 0
            languagesHashIncorrect[conceptHash.name] = 0
          end

          puts 'Language correct size = ' + languagesHashCorrect.keys.to_s
          puts 'Language incorrect size = ' + languagesHashIncorrect.keys.to_s

          # Se recorren cada uno de los examenes del usuario actual
          for exam in actualExams do
            questions = exam.questions # preguntas del examen
            for question in questions do
              correctAns = question.correctAns # respuesta correcta del examen
              givenAns = question.givenAns # respuesta contestada
              masterquestion = MasterQuestion.where('id = ?', question.master_question_id).first

              if masterquestion.language.id == language.id
                if correctAns == givenAns
                  puts 'Entre respuesta correcta'
                  languagesHashCorrect[masterquestion.concept.name] = languagesHashCorrect[masterquestion.concept.name] + 1
                else
                  languagesHashIncorrect[masterquestion.concept.name] = languagesHashIncorrect[masterquestion.concept.name] + 1
                end
              end
              # puts "Retroalimentacion => " + masterquestion.concept.name.to_s
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
      for e in MasterExam.where('user_id = ?', @current_user.id) do
        for q in e.master_questions do
          actualQuestions = q.questions

          if actualQuestions.length > 0
            right = actualQuestions.map { |a| right_answer? a }
            right = right.reduce { |sum, x| sum + x }

            if @questions_agg.key? q
              @questions_agg[q][0] += right
              @questions_agg[q][1] += (actualQuestions.length - right)
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
      @examName = MasterExam.find(@examId).name
      @cantakes = Cantake.where('master_exam_id = ?', @examId).order ('user_id')
      @h = {}
      for c in @cantakes do
        exams_result = []
        @exams =  Exam.where('master_exam_id = ? and user_id=?', @examId, c.user_id)
        for e in @exams do
          exams_result.push(e)
        end
        @h[c.user_id] = exams_result
      end
      # Estadisticas para las preguntas de examen por concepto/subconcepto
      @exams_taken = MasterExam.where('user_id = ? AND id = ?', @current_user.id, @examId).first.exams

      @q_taken = @exams_taken.map { |e| e.questions }
      @q_taken = @q_taken.flatten

      q_info = @q_taken.map { |q| [MasterQuestion.find(q.master_question_id).language.name.capitalize, MasterQuestion.find(q.master_question_id).concept.name.capitalize, MasterQuestion.find(q.master_question_id).sub_concept.name.capitalize, right_answer?(q)] }

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

    @cantakes = Cantake.where('master_exam_id = ?', @examId).order ('user_id')
    @h = {}
    for c in @cantakes do
      exams_result = []
      @exams =  Exam.where('master_exam_id = ? and user_id=?', @examId, c.user_id)
      for e in @exams do
        exams_result.push(e)
      end
      @h[c.user_id] = exams_result
    end

    @cantakes.each do |can|
      cont = 1
      @examenes = ExcelFormat.new
      if !@h[can.user_id].empty?
        # format.html
        # format.csv { send_data @products.to_csv }
        # format.xls { send_data can.user.name.to_csv(col_sep: "\t") }
        # can.user.username
        # arr.push(can.user.username)
        # @examenes.usuario = can.user.username
        @h[can.user_id].each do |_h|
          @examenes_anidados = ExcelFormat.new
          @examenes_anidados.usuario =  can.user.username
          # cont
          # format.xls { send_data cont.to_csv(col_sep: "\t") }
          # format.xls { send_data @h[can.user_id][cont-1].score.to_csv(col_sep: "\t")  }
          # @examenes.usuario  = n il
          @examenes_anidados.intentos = co nt
          @examenes_anidados.resultados = @h[can.user_id][cont - 1].sco re
          @examenes_anidados.save
          # @examenes.usuario  = nil
          cont = cont + 1
        end
     else
       @examenes.usuario = can.user.username
       @examenes.intentos  = 0.0
       @examenes.resultados = 0
       @examenes.save
       # can.user.username
       # format.xls { send_data can.user.name.to_csv(col_sep: "\t") }
       # format.xls { send_data zero.to_csv(col_sep: "\t") }
       # 0
     end

    end
    @examenest = ExcelFormat.select('usuario ,intentos, resultados').order(:usuario)

    respond_to do |format|
      format.html
      format.csv { send_data @examenest.to_csv }
      format.xls # { send_data @examenest.to_csv(col_sep: "\t") }
    end
    ExcelFormat.delete_all
  end
end
