class UserMailer < ActionMailer::Base
  default from: "julia.itesm@gmail.com"

   def welcome_email(user)
    @user = user
    @url  = 'http://twitter.com/'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end


end
