# encoding: utf-8
class ApplicationController < ActionController::Base
  helper_method :check_admin
  helper_method :check_prof
  helper_method :check_student

  protect_from_forgery

  protected

  def authenticate_user
    return true if current_user
    redirect_to('/signup')
    false
  end

  def authenticate_admin
    if current_user
      if check_admin
        return true
      else
        flash[:error] = 'Acceso restringido.'
        redirect_to(root_path)
        return false
      end
    else
      redirect_to('/signup')
      return false
    end
  end

  def save_login_state
    return true unless session[:user_id]
    redirect_to(root_path)
    false
  end

  def check_admin
    current_user && current_user.admin?
  end

  def check_prof
    current_user && current_user.professor?
  end

  def check_student
    current_user && current_user.student?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
