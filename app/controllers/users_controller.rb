# encoding: utf-8
class UsersController < ApplicationController
  # before_filter :save_login_state, :only => [:new, :create]
  before_filter :authenticate_user, only: [:index, :show, :edit, :update,
                                           :destroy, :change_admin,
                                           :change_professor, :change_student]

  def index
    if check_admin
      @users = User.all
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def new
    @user = User.new
  end

  def signup
    if session[:user_id].nil?
      @user = User.new
    else
      user = User.find(session[:user_id])
      redirect_to(user)
    end
  end

  def create
    @user = User.new(params[:user])
    @user.utype = 0

    if @user.save
      flash[:notice] = 'usuario creado de manera exitosa. haga sign in.'
    else
      if @user.errors.messages[:username]
        flash[:error] = 'El nombre de usuario no es único'
      elsif @user.errors.messages[:mail]
        flash[:error] = 'El correo no es único'
      else
        flash[:error] = 'Hubo un error al crear el usuario'
      end
    end

    redirect_to('/signup')
  end

  def show
    if check_admin || @current_user.id.to_s == params[:id]
      @user = User.find(params[:id])
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def edit
    if check_admin || @current_user.id.to_s == params[:id]
      @user = User.find(params[:id])
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def update
    if check_admin || @current_user.id.to_s == params[:id]
      @user = User.find(params[:id])

      if @user.update_attributes(params[:user])
        flash[:notice] = 'El usuario fue actualizado de manera correcta.'
        else
          flash[:error] = 'No se pudieron actualizar los datos del usuario.'
        end

      redirect_to(@user)
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def destroy
    if check_admin
      @user = User.find(params[:id])
      @user.destroy
      redirect_to action: 'index'
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def get_users
    if check_prof
      tempStr = ''
      @users = {}
      hash = params[:groups_ids_]
      hash.each_with_index do |h, index|
        tempStr += "#{h[1][:id]}"
        tempStr += ',' if index < (hash.length - 1)
      end
      if tempStr != ''
        u = User.joins(:groups).select('DISTINCT users.id').where("groups_users.group_id in (#{tempStr})")
        @users = User.select('DISTINCT id, username, fname, lname, mail').where('id not in (?)', u)
      else
        @users = User.where("id != #{session[:user_id]}")
          .select('DISTINCT users.id, users.username, users.fname, users.lname, users.mail')
      end
      respond_to { |format| format.json { render json: @users.to_json } }
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def get_current_user
    respond_to do |format|
      format.json { render json: session[:user_id].to_json }
    end
  end

  def set_users_cantake
    if check_prof
      exam_name = params[:exam_name]
      checked_groups = params[:checked_groups]
      usersFromGroups = []
      thisMasterExam = MasterExam.where(name: exam_name).where(user_id: session[:user_id]).last
      checked_groups.each do |group_id|
        usersFromGroups = Group.find(group_id).users
        usersFromGroups.each do |user|
          if !Cantake.exists?(master_exam: thisMasterExam, user_id: user[:id], group_id: group_id)
            cantake = Cantake.new
            cantake.master_exam = thisMasterExam
            cantake.user_id = user[:id]
            cantake.group_id = group_id
            cantake.save!
          else
            logger.info @collection.inspect
          end
        end
      end
      usersFromGroups = User.joins(:groups).where('groups_users.group_id in (?)', checked_groups)

      respond_to do |format|
        format.json { render json: usersFromGroups.to_json }
      end
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  # Used for setting up cantake for exercise purposes
  def set_user_cantake_own
    if authenticate_user
      exam_name = params[:exam_name]
      thisMasterExam = MasterExam.where(name: exam_name).where(user_id: session[:user_id]).last

      unless Cantake.exists?(master_exam: thisMasterExam, user_id: session[:user_id])
        cantake = Cantake.new
        cantake.master_exam_id = thisMasterExam.id
        cantake.user_id = session[:user_id]
        cantake.save!
        end

      respond_to do |format|
        format.json { render json: usersFromGroups.to_json }
      end
    else
      flash[:error] = 'Acceso restringido.'
      redirect_to(root_path)
    end
  end

  def change_admin
    if check_admin
      user = User.find(params[:id])
      user.utype = User::ADMIN
      if user.save
        redirect_to '/users'
      else
        flash[:error] = 'No se pudo hacer administrador al usuario.'
      end
    else
      flash[:error] = 'Necesita ser administrador para modificar el tipo de un usuario.'
    end
  end

  def change_professor
    if check_admin
      user = User.find(params[:id])
      user.utype = User::PROFESSOR
      if user.save
        redirect_to '/users'
      else
        flash[:error] = 'No se pudo hacer profesor al usuario.'
      end
    else
      flash[:error] = 'Necesita ser administrador para modificar el tipo de un usuario.'
    end
  end

  def change_student
    if check_admin
      user = User.find(params[:id])
      user.utype = User::STUDENT
      if user.save
        redirect_to '/users'
      else
        flash[:error] = 'No se pudo hacer estudiante al usuario.'
      end
    else
      flash[:error] = 'Necesita ser administrador para modificar el tipo de un usuario.'
    end
  end
end
