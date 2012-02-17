require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Rapnd::Daemon" do
  before do
    @daemon = Rapnd::Daemon.new(:redis_port => 9876, :cert => '', :dir => '.')
  end
  
  it "initializes a redis connection" do
    @daemon.redis.ping.should == "PONG"
  end
end
