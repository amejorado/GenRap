# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
GenRap::Application.initialize!

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_content_type = "text/html"

ActionMailer::Base.server_settings = {
   :address => "smtp.gmail.com",
   :port => 587,
   :domain => "codeafeliz.com",
   :authentication => :login,
   :user_name => "julia.itesm@gmail.com",
   :password => "love_love",
}
