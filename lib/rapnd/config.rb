module Rapnd
  module Config
    extend self
    
    def option(name, options = {})
      defaults[name] = settings[name] = options[:default]

      class_eval <<-RUBY
        def #{name}
          settings[#{name.inspect}]
        end

        def #{name}=(value)
          settings[#{name.inspect}] = value
        end

        def #{name}?
          #{name}
        end
      RUBY
    end
    
    def defaults
      @defaults ||= {}
    end
    
    def settings
      @settings ||= {}
    end
    
    option :redis_host, :default => 'localhost'
    option :redis_port, :default => 6879
    option :redis_password
  end
end