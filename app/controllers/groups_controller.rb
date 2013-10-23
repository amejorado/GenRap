#encoding: utf-8
class GroupsController < ApplicationController

	before_filter :authenticate_user, :only => [:index, :new, :create]

	def index
		if check_admin
			@groups = Group.all
		elsif check_prof
			#@groups = @current_user.groups
			@groups = Group.where(user_id: session[:user_id])
		else
			flash[:error] = "Usted necesita ser un administrador para accesar esta página."
			redirect_to(root_path)
		end
	end

	def new
		@group = Group.new
	end

	def create
		if check_prof
			@group = Group.new(params[:group])
			@group.user = User.find(params[:profesor])
			#if !@group.users.include? @current_user
			#	@group.users << @current_user
			#end

			puts "GROUP CONTROLLER " + @group.users.to_s  			

			group_file = params[:upload]
			to_add = '';
			if group_file.respond_to?(:read)
			  to_add = group_file.read
			elsif group_file.respond_to?(:path)
			  to_add = File.read(group_file.path)
			else
			  logger.error "Bad group_file: #{group_file.class.name}: #{group_file.inspect}"
			end
			to_add = to_add.gsub(/\r\n?|\n/, ",")
			users = to_add.split(/,/)
			errors = []
			users.each do |user|
				user = user.gsub(/\s+|\n+|\r+/, "")
				if (user == "") 
					next
				end
				curr_user = User.find_by_username(user)
				if(curr_user == nil)
					errors << ("Usuario <b>" + user + "</b> no encontrado.")
				else
					params[:group][:user_ids] << curr_user.id
				end
			end
			if errors.length > 0
				flash[:error] = errors.join("<br />").html_safe
			end
			if @group.save
				flash[:notice] = "Grupo creado de manera exitosa."
				redirect_to(groups_path)
			else
				flash[:error] = "Datos del grupo no válidos."
				redirect_to(new_group_path)
			end
		else
			flash[:error] = "Acceso restringido."
			redirect_to root_path
		end
	end

	def show
		if check_prof
			@group = Group.find(params[:id])
		else
			flash[:error] = "Acceso restringido."
			redirect_to root_path
		end
	end

	def edit
		if check_prof
			@group = Group.find(params[:id])
		else
			flash[:error] = "Acceso restringido."
			redirect_to root_path
		end
	end

	def update
		if check_prof
			@group = Group.find(params[:id])
		 
			group_file = params[:upload]
			to_add = '';
			if group_file.respond_to?(:read)
			  to_add = group_file.read
			elsif group_file.respond_to?(:path)
			  to_add = File.read(group_file.path)
			else
			  logger.error "Bad group_file: #{group_file.class.name}: #{group_file.inspect}"
			end
			to_add = to_add.gsub(/\r\n?|\n/, ",")
			users = to_add.split(/,/)
			errors = []
			users.each do |user|
				user = user.gsub(/\s+|\n+|\r+/, "")
				if (user == "") 
					next
				end
				curr_user = User.find_by_username(user)
				if(curr_user == nil)
					errors << ("Usuario <b>" + user + "</b> no encontrado.")
				else
					params[:group][:user_ids] << curr_user.id
				end
			end
			if errors.length > 0
				flash[:error] = errors.join("<br />").html_safe
			end
			
			if @group.update_attributes(params[:group])
				flash[:notice] = 'El grupo fue actualizado de manera correcta.'
		    else
		    	flash[:error] = "No se pudieron actualizar los datos del grupo."
		    end

		    redirect_to(@group)
		else
			flash[:error] = "Acceso restringido."
			redirect_to root_path
		end
	end

	def destroy
		if check_prof
			@group = Group.find(params[:id])
			@group.destroy

			redirect_to :action => 'index'
		else
			flash[:error] = "Acceso restringido."
			redirect_to root_path
		end
	end

	def get_groups
		if check_prof
			@groups = Group.where(user_id: session[:user_id]).select("name, id")
		    respond_to do |format|
		      format.json { render json: @groups.to_json }
		    end
		end
  	end
end