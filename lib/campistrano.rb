module Campistrano

  require 'rubygems'
  require 'tinder'

  def self.config
    @config
  end

  def self.initialize(&block)
    @config = Campistrano::Config.new(&block)
  end

  after "deploy", "deploy:notify_campfire"

  task :notify_campfire do
    deployer = `whoami`.strip
    campfire_notify "#{deployer} just deployed to #{rails_env} environment at #{branch}"
  end

  class Config 
    attr_accessor :username, :token, :ssl
    def initialize(&block)
      block.call(self)
    end
  end

  class Notifier
    def client
      @client ||= Tinder::Campfire.new Campistrano.config.username, :token => Campistrano.config.token, :ssl => config.ssl
    end

    def env
      defined?(Rails) ? Rails.env : ''
    end

    def notify(room, message)
      room      = client.find_room_by_name(room)
      room.speak "[deploy@#{env}] #{message}"
    end
  end

end

include Campistrano
