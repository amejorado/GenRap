class UserMailer < ActionMailer::Base
  default from: "info@codigofeliz.com"

   def welcome_email(user)
    @user = user
    @url  = 'http://twitter.com/'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end


end
