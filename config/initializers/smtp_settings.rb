ActionMailer::Base.default :content_type => "text/html"
ActionMailer::Base.delivery_method = "smtp"
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "codeafeliz.com",
  :user_name            => "julia.itesm@gmail.com",
  :password             => "love_love",
  :authentication       => "login",
  :enable_starttls_auto => false
}