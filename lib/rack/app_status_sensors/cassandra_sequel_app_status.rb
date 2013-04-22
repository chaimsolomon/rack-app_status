class AppStatusSensors
  def cassandra_cequel
    if Cequel::Model.keyspace.connection.active?
      :ok
    else
      :not_connected
    end
  end
end
