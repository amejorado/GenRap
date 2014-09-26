# encoding: utf-8
class ExamsController < ApplicationController
  helper_method :who_cantake_masterExam

  def new
    @exam = Exam.new
  end

  def index
    if current_user.admin?
      @masterExams = MasterExam.all
    elsif current_user.professor?
      @masterExams = MasterExam.where(user: current_user)
    end
  end

  def pending
    @masterExams = []
    @attempts_exams = []

    @masterExercises = []
    @exer_info = []

    # Se obtienen los examenes cuya fecha de inicio sea menor a la actual y
    # fecha de termino sea mayor a la actual
    # Además, estos deben ser creados por personas diferentes al usuario actual
    now = Time.zone.now
    availableExams = MasterExam.where('startDate <= ? AND finishDate >= ?',
                                      now, now).where('user_id <> ?', current_user)

    # Para cada uno de estos examenes, se agrega el master exam y los intentos
    # actuales a los arreglos correspondientes
    availableExams.each do |masterExam|
      # Se obtienen los usuarios relacionados con este examen
      validUsers = who_cantake_masterExam(masterExam.id)
      # Se valida que el usuario actual sea un usuario valido y que haya
      # intentos restantes
      times_answered = Exam.where(master_exam_id: masterExam,
                                  user_id: @current_user).count
      if validUsers.include?(@current_user.id) &&
        times_answered < masterExam.attempts

        @masterExams.push(masterExam)
        # Se agrega a la lista de intentos, la cantidad de intentos del
        # examen encontrado
        @attempts_exams << Exam.where(master_exam_id: masterExam,
                                      user_id: @current_user).count
      end
    end

    # Se obtienen los examenes (ejercicios) creados por uno mismo, como ejercicios
    availableExercices = MasterExam.where(user_id: @current_user)

    # Para cada uno de estos examenes, se agrega el master exam y el promedio
    # de los intentos actuales a los arreglos correspondientes
    availableExercices.each do |masterExam|
      # Se obtienen los usuarios relacionados con este examen
      validUsers = who_cantake_masterExam(masterExam.id)
      # Se valida que el usuario actual sea un usuario valido
      if validUsers.include?(@current_user.id)
        actual_exams = Exam.where(master_exam_id: masterExam,
                                  user_id: @current_user)
        @masterExercises << masterExam
        if actual_exams.length > 0
          grade = actual_exams.map(&:score).reduce { |sum, x| sum + x }
          grade = grade / actual_exams.length.to_f
        else
          grade = '-'
        end
        @exer_info << [grade, actual_exams.length]
      end
    end
  end

  def sendEmailExam(user, idExam)
    userName = user[0].fname
    userMail = user[0].mail
    url  = 'http://codeafeliz.com/exams/' + idExam.to_s
    data = Multimap.new
    data[:from] = 'Codea Feliz Team <info@codigofeliz.com>'
    data[:to] = userMail
    data[:subject] = 'Codea Feliz Feedback'
    data[:html] = "
    <html>
      <h2>Codea Feliz Feedback </h1><hr/>
      <h3>Buen día " + userName + ",</h3>
        <h4>
          Has contestado un examen en CodeaFeliz.<br/>
          Para ver tus resultados puedes ingresar al siguiente link: " + url + "
        </h4>
        <h4>Gracias por usar CodeaFeliz!</h4>
    </html>"
    begin
      RestClient.post 'https://api:key-4e3j9-vt6dvv9al93usavq800of2j6l3@api.mailgun.net/v2/mg.scitus.mx/messages', data
    rescue => e
      logger.info 'Error al enviar el correo electronico'
    end
  end

  def afterExam
    @masterExams = []
    @attempts_exams = []

    @masterExercises = []
    @exer_info = []

    # id del examen presentado
    @answeredExam = Exam.find(params[:id])
    # usuario que presento el examen
    @userOfExam = User.select('fname, mail').where(id: @answeredExam.user_id)
    # manda llamar metodo que envia el correo
    sendEmailExam(@userOfExam, @answeredExam.id)
    # redireccionar a pagina principal
    redirect_to(pending_path)
  end

  def create
    masterExam = MasterExam.find(params[:id])
    @attempts = Exam.where(master_exam_id: params[:id], user_id: current_user).count
    validUsers = who_cantake_masterExam(masterExam.id)

    if available(masterExam) && (current_user.professor? || validUsers.include?(current_user.id))

      # Se crea una instancia del examen para el usuario actual
      exam = Exam.createInstance(params[:id], current_user.id)
      if !exam.nil?
        # Redirigir a editar el examen para contestarlo
        redirect_to action: 'edit', id: exam.id
      elsif @attempts >= masterExam.attempts
        flash[:notice] = 'Numero de intentos excedido.'
        redirect_to(pending_path)
      else
        flash[:error] = 'Error al crear el exámen. Intentos actuales: ' + @attempts.to_s + '.'
        redirect_to(pending_path)
      end
    # Modificar el estado del master exam de dicho usuario
    # @masterExam = MasterExam.find(params[:id])
    # Disminuir un intento cuando se entra al examen
    # @masterExam.attempts = @masterExam.attempts - 1;
    else
      flash[:error] = 'Exámen no disponible.'
      redirect_to(pending_path)
    end
  end

  def edit
    # Se verifica que el administrador sea el que está editando o que el examen
    # sea del usuario actual y que el estado del examen sea 0 (creado)
    @exam = Exam.find(params[:id])
    if current_user.professor? || (current_user.id.to_i == @exam.user_id.to_i && @exam.state.to_i == 0)
      # Declarar el examen como comenzado
      @examName = @exam.master_exam.name
      # master_examen es un objeto
      @examenMaestro = @exam.master_exam
      # Se guarda el examen para cambiarse a comenzado
      unless @exam.save
        flash[:error] = 'Error al obtener el examen.'
        redirect_to(pending_path)
      end
    end
  end

  def show
    @exam = Exam.find(params[:id])
    if current_user.professor? || current_user.id == @exam.user_id
      @masterExamId = @exam.master_exam_id
      @examName = MasterExam.find(@masterExamId).name
    end
  end

  def update
    @exam = Exam.find(params[:id])
    if current_user.professor? || current_user.id == @exam.user_id
      masterExam = @exam.master_exam

      # Checar que la fecha del examen sea valida
      now = Time.zone.now
      if masterExam.startDate <= now && masterExam.finishDate >= now
        examenTomado = @exam
        # checara que la hora en la que se guarda el servidor esta dentro del
        # tiempo de duración y 30 segundos del alert que muestra
        horaMaxima = examenTomado.date
        horaMaxima += (masterExam.duracion * 60) + 30
        if now <= horaMaxima
          score = 0
          masterExamId = masterExam.id

          # Para cada pregunta, se verifica la respuesta
          @exam.questions.each do |question|

            masterQuestionId = question.master_question_id
            questionId = params[':questions'][question.id.to_s]
            givenAns = questionId['givenAns']
            question.update_attributes(givenAns: givenAns)

            # Si la respuesta dada es correcta, se agrega la cantidad al score
            if givenAns == question.correctAns
              questionNum = question.questionNum
              examDef = ExamDefinition.where(master_exam_id: masterExamId,
                                             master_question_id: masterQuestionId,
                                             questionNum: questionNum).first
              weight = examDef.weight
              score = score + weight * 100
            end
          end

          # Se actualiza el score del examen
          if @exam.update_attributes(score: score)
            flash[:notice] = 'El exámen fue registrado de manera correcta.'
            redirect_to action: 'results', id: @exam.id
          else
            flash[:error] = 'Error al guardar el exámen.'
            redirect_to(root_path)
          end
        end
      else
        flash[:error] = 'Examen no disponible.'
        redirect_to(root_path)
      end
    end
  end

  def results
    exam = Exam.find(params[:id])
    validUsers = []
    validUsers << exam.user_id

    masterExam = MasterExam.find(exam.master_exam_id)
    examCreator = masterExam.user_id

    validUsers << examCreator

    if current_user.professor? || validUsers.include?(current_user.id)
      @exam = exam
    else
      redirect_to(root_path)
    end
  end

  private

  # gets a list of users that can take the masterExam
  def who_cantake_masterExam(masterExamId)
    masterExam = MasterExam.find(masterExamId)
    masterExam.cantakes.map(&:user_id)
  end

  def available(masterExam)
    now = Time.zone.now
    masterExam.user_id == current_user.id ||
      (masterExam.startDate <= now && masterExam.finishDate >= now)
  end
end
