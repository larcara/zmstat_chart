require 'mongo'



class ZmstatChart

  TIME_STAMP_FORMAT = "%m/%d/%Y %H:%M:%S"
  LOGGER_OUT = STDOUT
  def initialize(db: "zmstats")
    @mongo_cnf = YAML::load_file(File.join(__dir__, 'config/mongo.yml'))

    @client = connect({ database: db})
    @log = Logger.new (LOGGER_OUT)
  end

  def connect(options)
    connection_options = @mongo_cnf["development"].merge(options)
    server=connection_options.delete("servers")
    _options={}
    connection_options.each do |k, v|
      _options[k.to_sym] = v
    end
    client = Mongo::Client.new(server, _options)
  end

  def upload_file(_file, collection)

    gz = Zlib::GzipReader.new(_file)

    headers = gz.readline.chomp.split(",").map(&:strip)
    result = []
    gz.each_line do |line|
      begin
        data = line.chomp.split(",")
        if DateTime.strptime(data[0],TIME_STAMP_FORMAT)
          json_data = {}
          headers.each_with_index { |h , i | json_data[h] = data[i] }
          json_data["timestamp"] = DateTime.strptime(json_data["timestamp"],TIME_STAMP_FORMAT)
          result << json_data
        end
      rescue
        puts "skip #{line}"
      end
    end
    _collection = @client[collection]

    _result = _collection.insert_many(result)
    gz.close
    return _result.inserted_count
  end

  def get_data(collection, field, skip: 0, limit:100)
    _collection = @client[collection]
    _collection.find({},{ 'projection' =>
                            { 'timestamp' => 1, field => 1 } }).skip(skip.to_i).limit(limit.to_i).map{|x| [x["timestamp"].to_i*1000, x[field].to_i ]}

  end
end




#zmstat= ZmstatChart.new()
#zmstat.upload_file("/media/psf/Untitled/zcsw01_stats/zmstat/pop3.csv", :pop3)
#zmstat.upload_file("/media/psf/Untitled/zcsw01_stats/zmstat/allprocs.csv", :allprocs)
