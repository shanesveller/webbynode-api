require 'rubygems'
gem 'httparty'
require 'httparty'

class WebbyNode
  class Client
    include HTTParty
    base_uri "https://manager.webbynode.com"
    format :xml

    attr_accessor :email, :api_key, :data

    def initialize(email, api_key)
      @email = email
      @api_key = api_key
      @data = self.auth_get('/api/xml/client')["hash"]["client"]
    end

    def auth_get(url, options = {})
      options[:query] ||= {}
      options[:query].merge!(:email => @email, :token => @api_key)
      self.class.get(url, options)
    end

    def method_missing(method)
      key = @data[method.to_s]
      key
    end
  end
end