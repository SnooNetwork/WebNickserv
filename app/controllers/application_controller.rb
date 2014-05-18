class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :require_login
  
  
  def require_login
    unless cookies.key? :login
      flash[:error]="You must be logged in to see this"
       session[:return_to] = request.fullpath
      redirect_to users_login_path
    end
  end
end
