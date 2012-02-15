require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Rapnd::Notification" do
  before do
    @notification = Rapnd::Notification.new(:badge => 99, :alert => 'Big test time', :custom_key => 'This is a test!', :spid => 1234, :device_token => '1234 5')
  end
  
  it 'removes whitespace from the device token' do
    @notification.device_token.should == '12345'
  end
  
  it "automatically assigns hash variables to instance variables" do
    @notification.badge.should == 99
    @notification.custom.should == {:custom_key => 'This is a test!', :spid => 1234}
  end
  
  it 'creates a hash payload' do
    @notification.payload.should == {:aps=>{:badge=>99, :alert=>"Big test time"}, :custom_key => "This is a test!", :spid => 1234}
  end
  
  it 'jsonifies the hash payload' do
    ActiveSupport::JSON.decode(@notification.json_payload).should == {"aps"=>{"badge"=>99, "alert"=>"Big test time"}, "custom_key"=>"This is a test!", "spid"=>1234}
  end
  
  it 'turns into bytes sensibly' do
    @notification.to_bytes.should == "\x00\x00 \x124P\x00W{\"aps\":{\"badge\":99,\"alert\":\"Big test time\"},\"custom_key\":\"This is a test!\",\"spid\":1234}"
  end
end
