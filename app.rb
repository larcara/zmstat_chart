require 'sinatra'
require_relative './zmstat_chart.rb'
require 'json'

set :bind, '0.0.0.0'
set :port,  80

get '/' do
  'Hello world!'
end

get "/allprocs" do
  erb :allprocs
end

get "/graph2" do
  @collection = params["collection"] || "pop3"
  @field = params["field"] || "exec_count"

  erb :graph2
end


get "/allprocs.json" do
  @zmstat = ZmstatChart.new()
  content_type :json
  @zmstat.get_data(:allprocs, params[:field], skip: params[:skip], limit: params[:limit]).to_json
end

