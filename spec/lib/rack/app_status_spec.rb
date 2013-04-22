require 'spec_helper'
require 'rack/app_status'
require 'active_record'
require 'cequel/model'

describe "Rack::AppStatus simple" do
  before(:each) do
    @mocked_app = double()
    @ars = Rack::AppStatus.new(@mocked_app, {:sensors => [:simple]})
  end

  describe "#call" do
    it "calls the app if PATH_INFO isn't app_status" do
      env = {'PATH_INFO' => "something"}
      @mocked_app.should_receive(:call).with(env)
      @ars.call(env)
    end

    it "doesn't call the app if PATH_INFO is app_status" do
      env = {'PATH_INFO' => "/app_status"}
      @mocked_app.should_not_receive(:call).with(env)
      @ars.call(env)
    end

    it "calls get_status if PATH_INFO is app_status and returns the response" do
      @ars.should_receive(:get_status).and_return ["something"]
      env = {'PATH_INFO' => "/app_status"}
      @ars.call(env).should == ["something"]
    end
  end

  describe "@get_status" do
    it "returns an OK" do
      @ars.get_status.should == [200, {'Content-Type' => 'text/plain'}, ["OK\n"]]
    end

    it "calls the simple sensor" do
      ass_inst = double("AppStatusSensors")
      AppStatusSensors.should_receive(:new).and_return(ass_inst)
      ass_inst.should_receive(:simple).and_return(:ok)
      @ars.get_status.should == [200, {'Content-Type' => 'text/plain'}, ["OK\n"]]
    end

    it "returns a 500 on the simple sensor not returning :ok" do
      ass_inst = double("AppStatusSensors")
      AppStatusSensors.should_receive(:new).and_return(ass_inst)
      ass_inst.should_receive(:simple).and_return(:nok)
      @ars.get_status.should == [500, {'Content-Type' => 'text/plain'}, ["nok"]]
    end
  end
end

describe "Rack::AppStatus ActiveRecord" do
  before(:each) do
    @mocked_app = double()
    @ars = Rack::AppStatus.new(@mocked_app, {:sensors => [:active_record]})
  end

  it "calls the active_record sensor" do
    ass_inst = double("AppStatusSensors")
    AppStatusSensors.should_receive(:new).and_return(ass_inst)
    ass_inst.should_receive(:active_record).and_return(:ok)
    @ars.get_status.should == [200, {'Content-Type' => 'text/plain'}, ["OK\n"]]
  end

  it "returns a 500 on the active_record sensor not returning :ok" do
    ass_inst = double("AppStatusSensors")
    AppStatusSensors.should_receive(:new).and_return(ass_inst)
    ass_inst.should_receive(:active_record).and_return(:nok)
    @ars.get_status.should == [500, {'Content-Type' => 'text/plain'}, ["nok"]]
  end

  it "returns a 500 on the active_record sensor not returning an error array" do
    ass_inst = double("AppStatusSensors")
    AppStatusSensors.should_receive(:new).and_return(ass_inst)
    ass_inst.should_receive(:active_record).and_return([500, {'Content-Type' => 'text/plain'}, ["XXX"]])
    @ars.get_status.should == [500, {'Content-Type' => 'text/plain'}, ["XXX"]]
  end

  describe "@get_status" do
    it "calls a select on the database to test the connection and returns a 200 if no error occurs" do
      connection_obj = double("connection")
      connection_obj.should_receive(:select_all).and_return(nil)
      ActiveRecord::Base.should_receive(:connection).and_return(connection_obj)
      @ars.get_status.should == [200, {'Content-Type' => 'text/plain'}, ["OK\n"]]
    end

    it "calls a select on the database to test the connection and returns a 500 if an exception is raised" do
      connection_obj = double("connection")
      ActiveRecord::Base.should_receive(:connection).and_raise(ActiveRecord::ConnectionNotEstablished)
      res = @ars.get_status
      res.should include(500)
      res.should include({"Content-Type"=>"text/plain"})
    end
  end
end

describe "Rack::AppStatus CassandraCequel" do
  before(:each) do
    @mocked_app = double()
    @ars = Rack::AppStatus.new(@mocked_app, {:sensors => [:cassandra_cequel]})
  end

  it "calls the cassandra_cequel sensor" do
    ass_inst = double("AppStatusSensors")
    AppStatusSensors.should_receive(:new).and_return(ass_inst)
    ass_inst.should_receive(:cassandra_cequel).and_return(:ok)
    @ars.get_status.should == [200, {'Content-Type' => 'text/plain'}, ["OK\n"]]
  end

  it "returns a 500 on the cassandra_cequel sensor not returning :ok" do
    ass_inst = double("AppStatusSensors")
    AppStatusSensors.should_receive(:new).and_return(ass_inst)
    ass_inst.should_receive(:cassandra_cequel).and_return(:nok)
    @ars.get_status.should == [500, {'Content-Type' => 'text/plain'}, ["nok"]]
  end

  it "returns a 500 on the cassandra_cequel sensor returning a :not_connected" do
    ass_inst = double("AppStatusSensors")
    AppStatusSensors.should_receive(:new).and_return(ass_inst)
    ass_inst.should_receive(:cassandra_cequel).and_return(:not_connected)
    @ars.get_status.should == [500, {'Content-Type' => 'text/plain'}, ["not_connected"]]
  end

  describe "@get_status" do
    it "calls active? on the connection and returns a 200 if it returns true" do
      connection_obj = double("connection")
      connection_obj.should_receive(:"active?").and_return(true)
      Cequel::Model.keyspace.should_receive(:connection).and_return(connection_obj)
      @ars.get_status.should == [200, {'Content-Type' => 'text/plain'}, ["OK\n"]]
    end

    it "calls active? on the connection and returns a 500 if it returns false" do
      connection_obj = double("connection")
      connection_obj.should_receive(:"active?").and_return(false)
      Cequel::Model.keyspace.should_receive(:connection).and_return(connection_obj)
      res = @ars.get_status
      res.should include(500)
      res.should include({"Content-Type"=>"text/plain"})
    end
  end
end
