require 'spec_helper'
require 'rack/app_status'
require 'active_record'

describe Rack::AppStatus do
  before(:each) do
    @mocked_app = double()
    @ars = Rack::AppStatus.new(@mocked_app)
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
