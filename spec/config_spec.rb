require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Rapnd::Config" do  
  it 'has a default value' do
    Rapnd.config.redis_host.should == 'localhost'
  end
  
  it 'overrides a default value with an assigner' do
    Rapnd.config.redis_host = 'testhost'
    
    Rapnd.config.redis_host.should == 'testhost'
  end
  
  it 'overrides a default value with a block' do
    Rapnd.config do |config|
      config.redis_host = 'testhost'
    end
    
    Rapnd.config.redis_host.should == 'testhost'
  end
  
  it 'checks a value has been assigned' do
    Rapnd.config.redis_host?.should be_true
    
    Rapnd.config.redis_host = nil
    
    Rapnd.config.redis_host?.should be_false
  end
end
