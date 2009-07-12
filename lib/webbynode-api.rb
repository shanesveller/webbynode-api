require 'rubygems'
gem 'httparty'
require 'httparty'

class WebbyNode
  class APIObject
    include HTTParty
    base_uri "https://manager.webbynode.com"
    format :xml

    attr_accessor :email, :api_key, :data

    # Creates a new API object secured by e-mail address and API token
    def initialize(email, api_key)
      @email = email
      @api_key = api_key
    end

    # Uses HTTParty to submit a secure API request via email address and token
    def auth_get(url, options = {})
      raise ArgumentError, "API information is missing or incomplete" unless @email && @api_key
      options[:query] ||= {}
      options[:query].merge!(:email => @email, :token => @api_key)
      results = self.class.get(url, options)
      raise ArgumentError, "Probable bad API information given" if results == {}
      return results
    end

    def auth_post(url, options = {})
      self.class.auth_post(url, options)
    end

    def self.auth_post(url, options = {})
      options[:query] ||= {}
      raise ArgumentError, "API information is missing or incomplete" unless options[:query][:email] && options[:query][:token]
      results = self.post(url, options)
      raise ArgumentError, "Probable bad API information given" if results == {}
      return results
    end

    # Catches simple requests for specific API data returned via a hash
    def method_missing(method)
      key = @data[method.to_s] if @data
      key
    end
  end
end

require File.join(File.dirname(__FILE__), 'webbynode-api', 'data')
