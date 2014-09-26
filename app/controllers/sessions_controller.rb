# encoding: utf-8
class SessionsController < ApplicationController
  def login
    authorized_user = User.find_by_username(params[:gusername].downcase)

    if authorized_user && authorized_user.authenticate(params[:gpassword])
      session[:user_id] = authorized_user.id
      flash[:notice] = "Bienvenido #{authorized_user.fname} #{authorized_user.lname}."
      if current_user.professor?
        redirect_to controller: 'stats', action: 'profstats'
      else
        redirect_to root_path
      end
    else
      flash[:error] = 'Usuario o password inválidos.'
      redirect_to('/signup')
    end
  end

  def self.find_for_database_authentication(conditions = {})
    unless conditions[:mail] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
      conditions[:username] = conditions.delete('mail')
    end
    super
  end

  def logout
    reset_session
    redirect_to '/signup'
  end
end
