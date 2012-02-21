require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Rapnd" do  
  before do
    Rapnd.config do |config|
      config.redis_host = 'localhost'
      config.redis_port = 9876
    end
    
    @redis = Redis.new(:host => 'localhost', :port => 9876)
  end
  
  it 'enqueues a message' do
    Rapnd.queue('test_queue', {:alert => 'Hi!'})
    
    @redis.llen('test_queue').should == 1
    Marshal.load(@redis.lpop('test_queue')).should == {:alert => 'Hi!'}
  end
  
  it 'gets a redis connection' do
    Rapnd.redis.ping.should == "PONG"
  end
end
