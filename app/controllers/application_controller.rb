class ApplicationController < ActionController::Base
  include ApplicationHelper


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    User.find( session[:user_id] ) if session[:user_id]
  end

  def require_login
    unless current_user
      flash[:error] = "You must be logged in to access this section"
      redirect_to root_path
    end
  end
end
