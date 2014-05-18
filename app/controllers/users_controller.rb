require "pp"
require 'xmlrpc/client'
class UsersController < ApplicationController
  def login
    if(not params.nil? and params.key? :login)
      pp "I have DATA"
      pp params
      server=XMLRPC::Client.new2("http://cosmos.snoonet.org:8080/xmlrpc")
      result=server.call("atheme.login",params[:login][:username],params[:login][:password],request.remote_ip)
      pp result
    end
  end
end
