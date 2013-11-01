
class EmailController < ApplicationController
   def sendmail
      email = @params["email"]
	  recipient = "rms.julle@gmail.com"
	  subject = "codea feliz"
	  message = "Prueba del correo de codigo feliz"
      UserEmail.deliver_contact(recipient, subject, message)
      return if request.xhr?
      render :text => 'Se mando exitosamente'
      redirect_to(root_path)
   end
end
