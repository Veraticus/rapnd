# rapnd

rapnd is an easy-to-use daemon that opens a persistent connection to the Apple Push Notification servers and sends notifications you specify to Apple.

It intentionally has very little in the way of model-level assumptions: this daemon is intended only to send notifications and does almost nothing to validate the content of the notifications (besides ensuring that the length is correct and a device_token is provided). Your models should validate that the messages they send to rapnd conform to the behavior you expect.

Each rapnd daemon operates on a separate resque queue, and multiple daemons can service one queue. Thus you can use rapnd with multiple Apple certs (if you have multiple applications you're trying to send notifications for) and, if you expect a lot of traffic, you can even have multiple daemons servicing one queue.

## Daemon usage

```
Usage: rapnd [options]
        --cert=MANDATORY             Location of the cert pem file
        --password=OPTIONAL          Password for the cert pem file
        --redis_host=OPTIONAL        Redis hostname
        --redis_port=OPTIONAL        Redis port
        --environment=OPTIONAL       Specify sandbox or production
        --queue=OPTIONAL             Name of the redis queue
        --foreground                 Run in the foreground
        --dir=OPTIONAL               Directory to start in
        --airbrake=OPTIONAL          Airbrake API key
        --help                       Show help
```

## Client usage

```ruby
require 'rapnd'

Rapnd.configure do |config|
  config.redis_host = 'localhost'
  config.redis_port = 6379
end

message = {:badge => 1, :alert => 'This is a test from rapnd!', :sound => 'flash.caf', :custom_properties => {:test_id => 1234, :happiness => true}}
queue_name = 'rapnd_queue'

Rapnd.queue(queue_name, message)
```

## Contributing to rapnd
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Josh Symonds. See LICENSE.txt for further details.