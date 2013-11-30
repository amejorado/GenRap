module ExamsHelper

	def format_values(values)
		JSON.parse("{" << values.gsub("-","").gsub(/(\^\d+)/,'"\\1"').gsub("\n",",").sub(",","").gsub(/(.*),(.*)/,'\\1\\2') << "}")
	end

	def format_answers(answers)
		#answers.gsub("-","").gsub("\n",",").sub(",","").gsub(/(.*),(.*)/,'\\1\\2').split(/,/)
		answers.gsub("\n",",").sub(",","").gsub(/(.*),(.*)/,'\\1\\2').split(/,/)
	end

		#Funcion que acomoada las respuestas de los examenes de manera aleatoria
	def random_answers(answers)
		#Se crea un arreglo temporal para guardar los valores en sus nuevas posiciones
		answersTemp = Array.new(answers.length+1, "0:0")
		answersTemp[0] = "0: Selecciona una opcion"
		count = answersTemp.length
		randNumber = Random.rand(1..answersTemp.length)
		i = 1
		i.to_i
		#Se recorre el arreglo de respuestas para cambiar las pocisiones
        while i < count 
        	#Si la posicion random ya tiene un valor asignado, se genera otro numero aleatorio
			while answersTemp[randNumber-1].to_s != "0:0"
				randNumber = Random.rand(1..answersTemp.length)
			end
			#Se guarda el valor del arreglo de respuetas en el arreglo temporal
			answersTemp[randNumber-1] = answers[i-1]
			i = i + 1
 		end

 		#Se regresa el arreglo temporal con los valores en las nuevas posiciones
 		return answersTemp
	end


	def check_correct_anwers(answers, correct)
		correctAnswer = answers[correct].to_s
		count = answers.length
		i = 0
		i.to_i
		while i < count 
	    	if i != correct
	    		if answers[i].to_s == correctAnswer
	    			if answers[i].to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) != nil
	    				answers[i] = answers[i] + Random.rand(1..10)
	    			end
	    		end
	    	end
			i = i + 1
		end
		return answers
	end
end