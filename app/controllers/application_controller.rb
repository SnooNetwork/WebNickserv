require 'xmlrpc/client'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :require_login
  
  def call_authenticated_command(*params)
    begin
      server=XMLRPC::Client.new2(Rails.configuration.atheme_server)
      result=server.call("atheme.command",cookies[:token],cookies[:login],request.remote_ip,*params)
      return result
    rescue XMLRPC::FaultException=>error
      if(error.faultCode==5)
        cookies[:login]=nil
        cookies[:token]=nil
        flash[:error]="You must be logged in to see this"
        session[:return_to] = request.fullpath
        redirect_to users_login_path
      else
        raise error
      end
    end
  end
  def require_login
    unless cookies.key? :login
      flash[:error]="You must be logged in to see this"
       session[:return_to] = request.fullpath
      redirect_to users_login_path
    end
  end
end
