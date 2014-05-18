require "pp"
require 'xmlrpc/client'

class UsersController < ApplicationController
  skip_before_action :require_login, only: [:login]
  def login
    if(not params.nil? and params.key? :login)
      @login=OpenStruct.new(params[:login])
      server=XMLRPC::Client.new2(Rails.configuration.atheme_server)
      begin
        
      
      result=server.call("atheme.login",params[:login][:username],params[:login][:password],request.remote_ip)
      cookies[:login]={:value=>params[:login][:username],:expires=>1.hour.from_now}
      cookies[:token]={:value=>result,:expires=>1.hour.from_now}
      flash[:success]="Logged you in."
      redirect_to(session[:return_to] || default)
      session[:return_to]=nil
      rescue XMLRPC::FaultException=>error
        flash.now[:error]=error.faultString
      end
      @login=OpenStruct.new(params[:login])
    else
      @login=OpenStruct.new
    end
  end
  def list
    server=XMLRPC::Client.new2(Rails.configuration.atheme_server)
    result=server.call("atheme.command",cookies[:token],cookies[:login],request.remote_ip,"NICKSERV","info",cookies[:login])
    results=result.split(/\n/)
    nickLine=''
    results.each do |res|
       parts=res.split(':')
       if(parts[0]=='Nicks      ')
         nickLine=parts[1]
       end
    end
    @nicks=nickLine.split(' ')
  end
end
