require 'mongo'


class ZmstatChart

  TIME_STAMP_FORMAT = "%m/%d/%Y %H:%M:%S"
  LOGGER_OUT = STDOUT
  def initialize
    @client = connect(server: "ds163360.mlab.com", port: 63360, db: "zmstats",  user: "zmstat", password: "zmstat")
    @log = Logger.new (LOGGER_OUT)
  end

  def connect(server: "127.0.0.1", port: "27017", db: "test",  user: "mongo", password: "")
    client = Mongo::Client.new([ "#{server}:#{port}" ], database: db, user: user, password: password)
  end

  def upload_file(file_path, collection)
    file = File.open(file_path)
    headers = file.readline.chomp.split(",").map(&:strip)
    result = []
    file.each_line do |line|
      data = line.chomp.split(",")
      json_data = {}
      headers.each_with_index { |h , i | json_data[h] = data[i] }
      json_data["timestamp"] = DateTime.strptime(json_data["timestamp"],TIME_STAMP_FORMAT)
      result << json_data
    end
    file.close
    _collection = @client[collection]

    _result = _collection.insert_many(result)
    return _result.inserted_count
  end

  def get_data(collection, field, skip: 0, limit:100)
    _collection = @client[collection]
    _collection.find({},{ 'projection' =>
                            { 'timestamp' => 1, field => 1 } }).skip(skip.to_i).limit(limit.to_i).map{|x| [x["timestamp"].to_i, x[field].to_f ]}

  end
end




#zmstat= ZmstatChart.new()
#zmstat.upload_file("/media/psf/Untitled/zcsw01_stats/zmstat/pop3.csv", :pop3)
#zmstat.upload_file("/media/psf/Untitled/zcsw01_stats/zmstat/allprocs.csv", :allprocs)
