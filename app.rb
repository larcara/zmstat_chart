require 'sinatra'
require_relative './zmstat_chart.rb'
require 'json'
require "haml"

set :bind, '0.0.0.0'
#set :port,  80

get '/' do
  'Hello world!'
end

get "/allprocs" do
  erb :allprocs
end

get "/graph2" do
  @collection = params["collection"] || "pop3"
  @field = params["field"] || "exec_count"
  @skip = params["skip"] || 0
  @limit = params["limit"] || 0
  erb :graph2
end


get "/data.json" do
  @zmstat = ZmstatChart.new()
  content_type :json
  @zmstat.get_data(params[:collection], params[:field], skip: params[:skip], limit: params[:limit]).to_json
end

get '/upload' do
  return haml(:upload)
end
post '/upload' do
    unless params[:file] &&
        (tmpfile = params[:file][:tempfile]) &&
        (name = params[:file][:filename]) && (coll = params[:coll])
      @error = "No file selected"
      return haml(:upload)
    end
    STDERR.puts "Uploading file, original name #{name.inspect}"
    @zmstat = ZmstatChart.new()
    @zmstat.upload_file(params[:file][:tempfile], coll.to_sym)

    "Upload complete"

end