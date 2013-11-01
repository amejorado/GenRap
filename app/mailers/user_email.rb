class UserEmail < ActionMailer::Base
   def contact(recipient, subject, message, sent_at = Time.now)
      @subject = 'Retroalimentacion'
      @recipients = recipient
      @from = 'no-reply@yourdomain.com'
      @sent_on = sent_at
	  @body["title"] = 'This is title'
  	  @body["email"] = 'rms.julle@gmail.com'
   	  @body["message"] = message
      @headers = {}
   end
end