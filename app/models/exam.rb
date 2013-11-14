#encoding: utf-8
class Exam < ActiveRecord::Base
  belongs_to :master_exam
  belongs_to :user
  has_many :questions

  validates :state,	:presence => true
  validates :score,	:presence => true,
  					:numericality => { :greater_than_or_equal_to => 0.0,
  										:less_than_or_equal_to => 100.0 }

  attr_accessible :date, :questions_attributes, :score, :id
  accepts_nested_attributes_for :questions

  before_save :check_attempts

  # private
	  def check_attempts
	  	state = self.state.to_i
		attempts = Exam.where("master_exam_id = ? and user_id = ?", self.master_exam_id, self.user_id).size
		allowedAttempts = MasterExam.find(self.master_exam_id).attempts
		if attempts > allowedAttempts || state >= 2
			false
		elsif state >= -1
		  	state = state + 1
		  	self.state = state.to_s
	  	else
	  		false
	  	end
	  end

	  def self.check_correct_answers(answers, correct)
		#Variables declaration/inicialization
		stringAnswers = ['Ninguna de las anteriores', 'Todas las anteriores']
		answersTemp = Hash.new ('')
		answersTemp[1] = answers[1]
		correctAnswer = answers[correct].to_s
		count = answers.length
		stringRepetidos = 0
		
		#Debugging variables
		#puts "Contador check_correct_answers " + count.to_s + " correctAnswer = " + correctAnswer
		#puts "The actual answers are = " + answers.to_s
		#puts "The temporal answers are = " + answersTemp.to_s 
		#puts "Temporal answers count = " + answersTemp.length.to_s


		answersIndex = 1
		temporalIndex = 1
		answersIndex.to_i
		temporalIndex.to_i

		#Se recorre todo el arreglo para revisar si existen valores repetidos
		while answersIndex <= count
			while temporalIndex <= answersTemp.length 
				#Se revisa que las respuestas no sean igual que la correcta
				if answersIndex != correct
					#Empieza prueba
						if answers[answersIndex].is_a? String
							puts "Encontre un string"
						end
					#Termina prueba

					#Revisa si la respuesta es igual a la respuesta correcta y si es igual la cambia
					if answers[answersIndex].to_s == correctAnswer
						answers[answersIndex] = answers[answersIndex] + Random.rand(1..100)
					end
					#Revisa si la respuesta esta repetida
					if answers[answersIndex] == answersTemp[temporalIndex]
						#Revisa si la respuesta es un string la cambia por otro string sino por un numero random
						if answers[answersIndex].is_a? String
							puts "Encontre un string"
							answers[answersIndex] = stringAnswers[stringRepetidos]
							stringRepetidos = stringRepetidos + 1
						else
							answers[answersIndex] = answers[answersIndex] + Random.rand(1..100)
						end
						#Revisa que la respuesta generada no sea igual a la correcta
						if answers[answersIndex].to_s == correctAnswer
							if answers[answersIndex].is_a? String
								puts "Encontre un string"
								answers[answersIndex] = stringAnswers[stringRepetidos]
								stringRepetidos = stringRepetidos + 1
							else
								answers[answersIndex] = answers[answersIndex] + Random.rand(1..100)
							end
							#answers[answersIndex] = answers[answersIndex] + Random.rand(1..100)
						end	
					end
				end
				temporalIndex = temporalIndex + 1
			end
			answersTemp[temporalIndex - 1] = answers[answersIndex]
			answersTemp[temporalIndex] = ""
			temporalIndex = 1
			answersIndex = answersIndex + 1
		end

		answersTemp.delete(answersTemp.length)

		return answersTemp
	  end


  def self.createInstance(master_exam_id, user_id)
  		# session = Hash.new
  		# session[:user_id] = 9

  		ActiveRecord::Base.transaction do
			exam = Exam.new

			# Create exam
			exam.master_exam = MasterExam.find(master_exam_id)
			exam.user = User.find user_id
			exam.state = "-1"
			exam.date = Time.now
			exam.score = 0
			
			user = User.find(user_id)
			
			if exam.master_exam.users.include? user
				attemptN = Exam.where("master_exam_id = ? and user_id = ?", master_exam_id, user_id).size

				if attemptN < exam.master_exam.attempts
					exam.attemptnumber = attemptN + 1

					if exam.save
						# flash[:notice] = "Examen creado de manera exitosa."
						puts "Examen creado de manera exitosa."
					else
						# flash[:error] = "No se pudo crear el examen."
						puts "No se pudo crear el examen."
						raise ActiveRecord::Rollback
					end
				else
					# flash[:error] = "Se han agotado los attempts."
					puts "Se han agotado los attempts."
					raise ActiveRecord::Rollback
				end
			else
				# flash[:error] = "Usuario no puede tomar este examen."
				puts "Usuario no puede tomar este examen."
				raise ActiveRecord::Rollback
			end

			# Create questions
			e_definition = ExamDefinition.where("master_exam_id = ?", master_exam_id)
			for mQuestion in e_definition
				master_question = MasterQuestion.find(mQuestion.master_question_id)
				inquiry = master_question.inquiry

				# We generate random question
				randomizer = master_question.randomizer
				full_randomizer_path = File.dirname(__FILE__) + "/../helpers/r/" + randomizer + '.rb'
				load full_randomizer_path
				puts "loaded " + full_randomizer_path
				values = randomize(inquiry)
				# puts "values " + values.to_s

				# We generate values, correctAns
				solver = master_question.solver
				full_solver_path = File.dirname(__FILE__) + "/../helpers/s/" + solver + '.rb'
				load full_solver_path
				puts "loaded " + full_solver_path
				answers, correctAns = solve(inquiry, values)
				answers = check_correct_answers(answers, correctAns)
				# puts "answers " + answers.to_s
				# puts "correctAns " + correctAns.to_s

				# We finally create the question
				question = Question.new
				# puts "exam " + exam.to_s
				question.exam = exam
				question.master_question = master_question
				question.questionNum = mQuestion.questionNum
				question.values = values
				question.answers = answers
				question.correctAns = correctAns
				question.givenAns = ""

				if question.save
					# flash[:notice] = "Pregunta creada de manera exitosa."
					puts "Pregunta creada de manera exitosa."
				else
					# flash[:error] = "No se pudo crear la pregunta."
					puts "No se pudo crear la pregunta."
					raise ActiveRecord::Rollback
				end
			end #end for

			#Return exam
			exam

		end  #end transaction
	end #end method

end
