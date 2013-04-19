require_relative 'app_status_sensors/simple_app_status'

class AppStatusSensors
  # This class contains the sensors that are used to determine if the app is running correctly or not.
  # The method names need to match the names of the symbol that is used in the initializer - and they are
  # (or can be) in individual files in the app_status_sensors subdirectory.
  # The sensor is called without arguments and returns either a symbol (:ok in the OK case) or an array
  # with HTTP code, header-hash and body: [500, {'Content-Type' => 'text/plain'}, [body]]
  # In case of multiple non-:ok responses, the first one will be passed back to the requester.
end


module Rack
  class AppStatus
    # Initialize the gem with a list of sensors - e.g. in your application.rb write something like
    #     config.middleware.use Rack::ActiveRecordStatus, :sensors => [:simple, :active_record]
    # If you add :path then that is used for the path of the app status page:
    #     config.middleware.use Rack::ActiveRecordStatus, :path => "/app", :sensors => [:simple, :active_record]
    # In this case the page would be at /app and not /app_status.
    # If you don't provide a :sensors list then actice_record is assumed. And :simple will be used too - though that
    # is somewhat pointless as it can't really fail.
    def initialize(app, options={})
      @app = app
      # Support legacy arguments (0.4.1 and below)
      options = {:path => options} if options.is_a?(String)

      @sensors = options[:sensors] || [:simple, :active_record]
      # Don't require non-configured backend modules to be around!
      if @sensors.include? :active_record
        require_relative 'app_status_sensors/active_record_app_status'
      end

      @path = options[:path] || '/app_status'
      @response = options[:response] || "OK\n"
    end

    def call(env)
      if @path == env['PATH_INFO']
        get_status
      else
        @app.call(env)
      end
    end

    def get_status
      sensors = AppStatusSensors.new
      ok_count = 0
      nok_list = []
      returns = @sensors.each do |modulename|
        r = sensors.send(modulename)
        if r == :ok
          ok_count += 1
        else
          unless r.is_a? Array
            r = [500, {'Content-Type' => 'text/plain'}, [r.to_s]]
          end
          nok_list << r
        end
      end
      unless nok_list.empty?
        return nok_list.first
      end
      if ok_count > 0
        [200, {'Content-Type' => 'text/plain'}, [@response]]
      else
        [500, {'Content-Type' => 'text/plain'}, ["NO SENSOR"]]
      end
    end
  end
end
