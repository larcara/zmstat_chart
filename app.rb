require 'sinatra'
require_relative './zmstat_chart.rb'
require 'json'

get '/' do
  'Hello world!'
end

get "/allprocs" do
  erb :allprocs
end

get "/allprocs.json" do
  @zmstat = ZmstatChart.new()
  content_type :json
  @zmstat.get_data(:allprocs, params[:field], skip: params[:skip], limit: params[:limit]).to_json
end