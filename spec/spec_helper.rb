$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rapnd'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with(:mocha)  
  config.before(:suite) do
    `redis-server #{File.dirname(__FILE__)}/redis-test.conf`
  end
  config.after(:suite) do
    processes = `ps -A -o pid,command | grep [r]edis-test`.split("\n")
    pids = processes.map { |process| process.split(" ")[0] }
    pids.each { |pid| Process.kill("KILL", pid.to_i) }
  end
end
