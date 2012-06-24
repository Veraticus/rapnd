require 'redis'
require 'openssl'
require 'socket'
require 'active_support/ordered_hash'
require 'active_support/json'
require 'base64'
require 'airbrake'
require 'logger'

module Rapnd
  class Daemon
    attr_accessor :redis, :host, :apple, :cert, :queue, :connected, :logger, :airbrake
    
    def initialize(options = {})
      options[:redis_host]  ||= 'localhost'
      options[:redis_port]  ||= '6379'
      options[:host]        ||= 'gateway.sandbox.push.apple.com'
      options[:queue]       ||= 'rapnd_queue'
      options[:password]    ||= ''
      raise 'No cert provided!' unless options[:cert]
      
      Airbrake.configure { |config| config.api_key = options[:airbrake]; @airbrake = true; } if options[:airbrake]
      
      redis_options = { :host => options[:redis_host], :port => options[:redis_port] }
      redis_options[:password] = options[:redis_password] if options.has_key?(:redis_password)
      
      @redis = Redis.new(redis_options)
      @queue = options[:queue]
      @cert = options[:cert]
      @host = options[:host]
      @logger = Logger.new("#{options[:dir]}/log/#{options[:queue]}.log")
      @logger.info "Listening on queue: #{self.queue}"
    end
    
    def connect!
      @logger.info 'Connecting...'
      @context      = OpenSSL::SSL::SSLContext.new
      @context.cert = OpenSSL::X509::Certificate.new(File.read(@cert))
      @context.key  = OpenSSL::PKey::RSA.new(File.read(@cert), @password)

      @sock         = TCPSocket.new(@host, 2195)
      self.apple    = OpenSSL::SSL::SSLSocket.new(@sock, @context)
      self.apple.sync = true
      self.apple.connect
      
      self.connected = true
      @logger.info 'Connected!'
      
      return @sock, @ssl
    end
    
    def run!
      loop do
        begin
          message = @redis.blpop(self.queue, 1)
          if message
            notification = Rapnd::Notification.new(JSON(message.last).symbolize_keys)
            self.connect! unless self.connected
            @logger.info "Sending #{notification.device_token}: #{notification.json_payload}"
            self.apple.write(notification.to_bytes)
          end
        rescue Exception => e
          if e.class == Interrupt || e.class == SystemExit
            @logger.info "Shutting down..."
            exit(0)
          end
          self.connect!
          if notification
            @logger.info "Trying again for: #{notification.json_payload}"
            self.apple.write(notification.to_bytes)
          end
          Airbrake.notify(e, {:environment_name => self.queue }) if @airbrake
          @logger.error "Encountered error: #{e}"
        end
      end
    end
  end
  
  def send_message(message)
    
  end
end