class AppStatusSensors
  def active_record
    begin
      # Check that the application is connected to the database
      ActiveRecord::Base.connection.select_all('select "app_status"')
      # Success
      :ok
    rescue
      body = ['ERROR', "#{$!.class}: #{$!.message}", "Backtrace:"] + $!.backtrace
      body *= "\n"
      [500, {'Content-Type' => 'text/plain'}, [body]]
    end
  end
end
