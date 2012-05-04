module Rapnd
  class Notification
    attr_accessor :badge, :alert, :sound, :content_available, :custom_properties, :device_token
    
    def initialize(hash)
      [:badge, :alert, :sound, :device_token, :content_available, :custom_properties].each do |k|
        self.instance_variable_set("@#{k}".to_sym, hash[k]) if hash[k]
      end
      raise "Must provide device token: #{hash}" if self.device_token.nil?
      self.device_token = self.device_token.delete(' ')
    end
    
    def payload
      p = Hash.new
      [:badge, :alert, :sound, :content_available].each do |k|
        p[k.to_s.gsub('_','-').to_sym] = send(k) if send(k)
      end
      aps = {:aps => p}
      aps.merge!(custom_properties) if custom_properties
      aps
    end
    
    def json_payload
      j = ActiveSupport::JSON.encode(payload)
      raise "The payload #{j} is larger than allowed: #{j.length}" if j.size > 256
      j
    end
    
    def to_bytes
      j = json_payload
      [0, 0, 32, self.device_token, 0, j.bytesize, j].pack("cccH*cca*").force_encoding('ASCII-8BIT')
    end
  end
end