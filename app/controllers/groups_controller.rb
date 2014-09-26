# encoding: utf-8
class GroupsController < ApplicationController
  def index
    if current_user.admin?
      @groups = Group.all
    elsif current_user.professor?
      @groups = current_user.groups_owned
    end
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.user = User.find(params[:profesor])

    puts 'GROUP CONTROLLER ' + @group.users.to_s

    group_file = params[:upload]
    to_add = ''
    if group_file.respond_to?(:read)
      to_add = group_file.read
    elsif group_file.respond_to?(:path)
      to_add = File.read(group_file.path)
    else
      logger.error "Bad group_file: #{group_file.class.name}: #{group_file.inspect}"
    end
    to_add = to_add.gsub(/\r\n?|\n/, ',')
    users = to_add.split(/,/)
    errors = []
    users.each do |user|
      user = user.gsub(/\s+|\n+|\r+/, '')
      next if user == ''
      curr_user = User.find_by_username(user)
      if curr_user.nil?
        errors << 'Usuario <b>' + user + '</b> no encontrado.'
      else
        params[:group][:user_ids] << curr_user.id
      end
    end
    flash[:error] = errors.join('<br />').html_safe if errors.length > 0
    if @group.save
      flash[:notice] = 'Grupo creado de manera exitosa.'
    else
      flash[:error] = 'Datos del grupo no válidos.'
    end
    redirect_to groups_path
  end

  def show
    @group = Group.find(params[:id])
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])

    params[:group][:user_ids].reject! { |c| c =~ c.empty? }
    group_file = params[:upload]
    to_add = ''
    if group_file.respond_to?(:read)
      to_add = group_file.read
    elsif group_file.respond_to?(:path)
      to_add = File.read(group_file.path)
    else
      logger.error "Bad group_file: #{group_file.class.name}: #{group_file.inspect}"
    end

    to_add = to_add.gsub(/\r\n?|\n/, ',')
    users = to_add.split(/,/)
    errors = []
    cantakes = Cantake.select('DISTINCT master_exam_id').where(group_id: @group)
    users.each do |user|
      user = user.gsub(/\s+|\n+|\r+/, '')
      next if (user == '')
      curr_user = User.find_by_username(user)
      if curr_user
        params[:group][:user_ids] << curr_user.id
      else
        errors << ('Usuario <b>' + user + '</b> no encontrado.')
      end
    end

    params[:group][:user_ids].each do |curr_user_id|
      next curr_user_id.empty?
      curr_user = User.find(curr_user_id)
      cantakes.each do |curr_cantake|
        next if Cantake.exists?(master_exam: curr_cantake.master_exam,
                                user_id: curr_user, group_id: @group)
        cantake = Cantake.new
        cantake.master_exam_id = curr_cantake.master_exam_id
        cantake.user = curr_user
        cantake.group_id = @group.id
        cantake.save!
      end
    end

    @cantakes = Cantake.where('group_id  = (?) and user_id not in (?)', @group.id, params[:group][:user_ids])
    @cantakes.destroy_all
    flash[:error] = errors.join('<br />').html_safe if errors.length > 0

    if @group.update_attributes(params[:group])
      flash[:notice] = 'El grupo fue actualizado de manera correcta.'
    else
      flash[:error] = 'No se pudieron actualizar los datos del grupo.'
    end

    redirect_to @group
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to action: 'index'
  end

  def get_groups
    @groups = Group.where(user_id: session[:user_id]).select('name, id')
    respond_to do |format|
      format.json { render json: @groups.to_json }
    end
  end
end
