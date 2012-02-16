require 'redis'
require 'openssl'
require 'socket'
require 'active_support/ordered_hash'
require 'active_support/json'
require 'base64'

module Rapnd
  class Daemon
    attr_accessor :redis, :host, :apple, :cert, :queue, :connected
    
    def initialize(options = {})
      puts 'Initializing daemon...'
      options[:redis_host]  ||= 'localhost'
      options[:redis_port]  ||= '6379'
      options[:host]        ||= 'gateway.sandbox.push.apple.com'
      options[:queue]       ||= 'rapnd_queue'
      options[:password]    ||= ''
      raise 'No cert provided!' unless options[:cert]
      
      @redis = Redis.new(:host => options[:redis_host], :port => options[:redis_port])
      @queue = options[:queue]
      @cert = options[:cert]
      @host = options[:host]
      puts "Listening on queue: #{self.queue}"
    end
    
    def connect!
      puts 'Connecting...'
      @context      = OpenSSL::SSL::SSLContext.new
      @context.cert = OpenSSL::X509::Certificate.new(File.read(@cert))
      @context.key  = OpenSSL::PKey::RSA.new(File.read(@cert), @password)

      @sock         = TCPSocket.new(@host, 2195)
      self.apple    = OpenSSL::SSL::SSLSocket.new(@sock, @context)
      self.apple.sync = true
      self.apple.connect
      
      self.connected = true
      puts 'Connected!'
      
      return @sock, @ssl
    end
    
    def run!
      message = @redis.blpop(self.queue, 1)
      if message
        notification = Rapnd::Notification.new(Marshal.load(message.last))
        self.connect! unless self.connected
        puts "Sending Apple: #{notification.json_payload}"
        self.apple.write(notification.to_bytes)
      end
      self.run!
    end
  end
end