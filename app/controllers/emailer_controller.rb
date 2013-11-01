
class EmailController < ApplicationController
   def sendmail
      email = @params["email"]
	  recipient = "rms.julle@gmail.com"
	  subject = "codea feliz"
	  message = "Gracias por presentar el examen, puedes revisar tus resultados en http://codeafeliz.com/exams/25"
      UserEmail.deliver_contact(recipient, subject, message)
      return if request.xhr?
      render :text => 'Se mando exitosamente'
      redirect_to(pending_path)
   end
end
