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
      redirect_to(session[:return_to] || root_path)
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
    result = call_authenticated_command "NICKSERV","info",cookies[:login]
    
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
  
  def delete
    call_authenticated_command  "NICKSERV","ungroup",params[:id]
    redirect_to user_path(cookies[:login])
  end
  
  def info
    begin
      result = call_authenticated_command  "NICKSERV","info",params[:id]
      results=result.split(/\n/)
      @info=Hash.new
      results.each do |res|
        parts=res.split(':')
        @info[parts[0].strip]=parts[1]
      end
    rescue XMLRPC::FaultException => error
      if(error.faultCode==4)
        flash[:error]="User Not Registered"
        if(not request.env["HTTP_REFERER"].nil? and not request.env["HTTP_REFERER"]==request.fullpath)
          redirect_to :back
          return
        end 
        redirect_to root_path
      end
    end
  end
end
