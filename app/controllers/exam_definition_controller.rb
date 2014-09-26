# encoding: utf-8
class ExamDefinitionController < ApplicationController
  def new
    @examDefinition = ExamDefinition.new
    @examUsers = nil

    if current_user.professor?
      render 'new'
    else
      render 'new_student'
    end
  end

  def create
    @examDefinition = ExamDefinition.new(params[:examID])
    @examDefinition.utype = 0

    if @examDefinition.save
      flash[:notice] = 'Definición de examen creada de manera exitosa.'
    else
      flash[:error] = 'Los datos no son válidos.'
    end
    redirect_to root_path
  end

  def destroy
    master_exam = MasterExam.find(params[:id])

    if current_user.admin? ||
       (current_user.professor? && master_exam.user_id == current_user.id)

      master_exam.destroy
      redirect_to '/profstats'
    end
  end

  def exam_def
    # este no debería de ir aquí pero marca error al intentarlo hacer en otro controlador
    # parece que una vez que hago un get en este controlador, ya no puedo cambiarlo.
    # por lo tanto los queries los voy a hacer aquí
    hash = params[:hash]
    exam_name = params[:exam_name]
    duracion_name = params[:duracion_name]
    number_of_attempts = params[:number_of_attempts]
    creationYear = params[:creationYear].to_i
    creationMonth = params[:creationMonth].to_i
    creationDay = params[:creationDay].to_i
    creationHour = params[:creationHour].to_i
    creationMinute = params[:creationMinute].to_i
    startYear = params[:startYear].to_i
    startMonth = params[:startMonth].to_i
    startDay = params[:startDay].to_i
    startHour = params[:startHour].to_i
    startMinute = params[:startMinute].to_i
    endYear = params[:endYear].to_i
    endMonth = params[:endMonth].to_i
    endDay = params[:endDay].to_i
    endHour = params[:endHour].to_i
    endMinute = params[:endMinute].to_i

    timeZone = 'Monterrey'

    master_exam = MasterExam.create(
      attempts: number_of_attempts,
      name: exam_name,
      duracion: duracion_name,
      dateCreation: Time.strptime("#{creationYear}-#{creationMonth}-#{creationDay} #{creationHour}:#{creationMinute}",
                                  '%Y-%m-%d %H:%M').in_time_zone(timeZone),
      startDate: Time.strptime("#{startYear}-#{startMonth}-#{startDay} #{startHour}:#{startMinute}",
                               '%Y-%m-%d %H:%M').in_time_zone(timeZone),
      finishDate: Time.strptime("#{endYear}-#{endMonth}-#{endDay} #{endHour}:#{endMinute}",
                                '%Y-%m-%d %H:%M').in_time_zone(timeZone),
      user: current_user
    )

    hash.each_with_index do |(key, _value), index|
      ExamDefinition.create(
        master_question: MasterQuestion.find(hash[key]['master_question_id'].to_i),
        master_exam: master_exam,
        questionNum: index + 1,
        weight: hash[key]['value'].to_f
      )
    end

    if current_user.professor?
      flash[:notice] = 'Examen agregado exitosamente'
    else
      flash[:notice] = 'Ejercicio creado exitosamente'
    end

    respond_to do |format|
      format.json { render json: hash.to_json }
    end
  end
end
