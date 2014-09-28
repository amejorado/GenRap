# encoding: utf-8
class ApplicationController < ActionController::Base
  helper_method :current_user
  before_filter :verify_can_access_action

  protect_from_forgery

  PUBLIC_PATHS = [{ controller_name: 'users', action_name: 'new' },
                  { controller_name: 'users', action_name: 'create' },
                  { controller_name: 'sessions', action_name: 'login' }]

  STUDENT_PATHS = [{ controller_name: 'sessions', action_name: 'logout' },
                   { controller_name: 'users', action_name: 'show' },
                   { controller_name: 'users', action_name: 'edit' },
                   { controller_name: 'users', action_name: 'update' },
                   { controller_name: 'exams', action_name: 'pending' },
                   { controller_name: 'exams', action_name: 'show' },
                   { controller_name: 'exams', action_name: 'create' },
                   { controller_name: 'exams', action_name: 'edit' },
                   { controller_name: 'exams', action_name: 'update' },
                   { controller_name: 'exams', action_name: 'results' },
                   { controller_name: 'exams', action_name: 'afterExam' },
                   { controller_name: 'stats', action_name: 'mystats' }]

  PROFESSOR_PATHS = STUDENT_PATHS + [
    { controller_name: 'exams', action_name: 'index' },
    { controller_name: 'exams', action_name: 'show' },
    { controller_name: 'exams', action_name: 'new' },
    { controller_name: 'exams', action_name: 'create' },
    { controller_name: 'exams', action_name: 'edit' },
    { controller_name: 'exams', action_name: 'update' },
    { controller_name: 'exams', action_name: 'results' },
    { controller_name: 'exam_definition', action_name: 'new' },
    { controller_name: 'exam_definition', action_name: 'exam_def' },
    { controller_name: 'exam_definition', action_name: 'destroy' },
    { controller_name: 'groups', action_name: 'index' },
    { controller_name: 'groups', action_name: 'show' },
    { controller_name: 'groups', action_name: 'get_groups' },
    { controller_name: 'master_questions', action_name: 'index' },
    { controller_name: 'master_questions', action_name: 'show' },
    { controller_name: 'stats', action_name: 'profstats' },
    { controller_name: 'stats', action_name: 'profstats_exam' },
    { controller_name: 'stats', action_name: 'resultadosExamen' },
    { controller_name: 'users', action_name: 'get_users' },
    { controller_name: 'users', action_name: 'set_users_cantake' },
    { controller_name: 'users', action_name: 'set_users_cantake_own' },
    { controller_name: 'users', action_name: 'get_current_user' },
    { controller_name: 'master_questions', action_name: 'get_languages' },
    { controller_name: 'master_questions', action_name: 'concepts_for_question' },
    { controller_name: 'master_questions', action_name: 'subconcepts_for_question' },
    { controller_name: 'master_questions', action_name: 'filtered_master_questions' }
  ]

  protected

  def verify_can_access_action
    path = { controller_name: controller_name, action_name: action_name }
    if current_user
      return if current_user.admin?
      unless (current_user.professor? && PROFESSOR_PATHS.include?(path)) ||
        (current_user.student? && STUDENT_PATHS.include?(path))
        flash[:error] = 'Acceso restringido.'
        redirect_to root_path
      end
    else
      redirect_to '/signup' unless PUBLIC_PATHS.include?(path)
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
