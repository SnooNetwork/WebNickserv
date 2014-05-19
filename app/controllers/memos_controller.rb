require "pp"
class MemosController < ApplicationController
  
  
  def new
    
  end
  def list
    memoRegex=/\- (?<id>\d+) From: (?<name>[a-zA-Z0-9\-_]+) Sent: (?<date>[\w\: ]+)/
    result=call_authenticated_command "MEMOSERV","LIST"
    results=result.split(/\n/)
    @memos=[]
    (2...results.count).each do |res|
      @memos+=[memoRegex.match(results[res])]
    end
  end
  def read
    readRegex=/Memo \d \- Sent by (?<name>[a-zA-Z0-9\-_]+), (?<date>[\w\: ]+)/
    result=call_authenticated_command "MEMOSERV","READ",params[:id]
    results=result.split(/\n/)
    @memo=[]
    (2..results.count).each do |res|
      @memo+=[results[res]]
    end
    match=readRegex.match(results[0])
    @name=match[:name]
    @date=match[:date]
    @id=params[:id]
  end
  
  def delete
    result=call_authenticated_command "MEMOSERV","DEL",params[:id]
    redirect_to memos_path
  end
end
