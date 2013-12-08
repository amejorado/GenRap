#encoding: utf-8
class SessionsController < ApplicationController

  # before_filter :authenticate_user, :only => [:home, :profile, :setting]
  # before_filter :save_login_state, :only => [:login]

  def login
  	authorized_user = User.find_by_username(params[:gusername].downcase)

  	if authorized_user && authorized_user.authenticate(params[:gpassword])
  		session[:user_id] = authorized_user.id
  		flash[:notice] = "Bienvenido #{authorized_user.fname} #{authorized_user.lname}."
      if check_admin
        redirect_to(root_path)
      elsif check_prof
          redirect_to(:controller => "stats", :action => "profstats")
      else
          redirect_to(root_path)
      end
  	else
  		flash[:error] = "Usuario o password inválidos."
  		redirect_to('/signup')  
  	end
  end

  def self.find_for_database_authentication(conditions = {} )
	unless conditions[:mail] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
		conditions[:username] = conditions.delete("mail")
	end
	super
  end
  

  # def home
  # end

  # def profile
  # end

  # def setting
  # end

  def logout
  	session[:user_id] = nil
  	redirect_to('/signup')
  end

end
