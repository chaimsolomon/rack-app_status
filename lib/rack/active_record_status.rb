require_relative 'app_status_sensors/simple_app_status'
require_relative 'app_status_sensors/active_record_app_status'

module Rack
  class ActiveRecordStatus
    def initialize(app, options={})
      @app = app
      # Support legacy arguments (0.4.1 and below)
      options = {:path => options} if options.is_a?(String)

      @status_modules = [:simple, :active_record]

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
      returns = @status_modules.each do |modulename|
        r = sensors.send(modulename)
        if r == :ok
          ok_count += 1
        else
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
