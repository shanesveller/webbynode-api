require 'rubygems'
gem 'httparty'
require 'httparty'

class WebbyNode

  # @author Shane Sveller
  # @since 0.0.1
  # @version 0.1.0
  class APIObject
    include HTTParty
    base_uri "https://manager.webbynode.com"
    format :xml

    # E-mail address used to access the WebbyNode API
    attr_accessor :email
    # API token used to access the WebbyNode API, visible at https://manager.webbynode.com/account
    attr_accessor :token
    # Stores the results of the HTTParty API interactions
    attr_accessor :data

    # Creates a new API object secured by e-mail address and API token
    #
    # @option options [String] :email e-mail address with API access
    # @option options [String] :token API token that matches the included e-mail address
    # @example Instantiates a new API access object
    #   WebbyNode::APIObject.new(:email => "example@email.com", :token => "123456abcdef")
    def initialize(options = {})
      raise ArgumentError, ":email and :token are required arguments" unless options[:email] && options[:token]
      @email = options[:email]
      @token = options[:token]
    end

    # Uses HTTParty to submit a secure API request via email address and token
    # @param [String] url URL to GET using HTTParty
    # @param [Hash] options Hash of additional HTTParty parameters
    # @option options [Hash] :query query hash used to build the final URL
    def auth_get(url, options = {})
      raise ArgumentError, "API information is missing or incomplete" unless @email && @token
      options[:query] ||= {}
      options[:query].merge!(:email => @email, :token => @token)
      results = self.class.get(url, options)
      raise ArgumentError, "Probable bad API information given" if results == {}
      return results
    end

    def auth_post(url, options = {})
      self.class.auth_post(url, options)
    end

    # Uses HTTParty to submit a secure API POST request via email address and token.
    # API access information should be included via the :email and :token hash keys,
    # in a hash on the :query key of the options hash passed as the second argument
    # in the method call.
    #
    # @param [String] url The URL to post to using HTTParty
    # @option options [String] :query query hash used to build the final URL
    #   Should include :email and :token keys with the e-mail address
    #   and API token with access rights
    # @return [Hash] returns a Hash of nested XML elements using string-based keys
    # @example Queries the API data for the client account
    #   WebbyNode::APIObject.auth_post("/api/xml/client", :query => {:email => ""example@email.com",
    #   :token => "1234567abcde", :posted_data => "test"})
    def self.auth_post(url, options = {})
      options[:query] ||= {}
      raise ArgumentError, "API information is missing or incomplete" unless options[:query][:email] && options[:query][:token]
      results = self.post(url, options)
      raise ArgumentError, "Probable bad API information given" if results == {}
      return results
    end

    # Catches simple requests for specific API data returned via a hash
    #
    # @return [Object, nil] If the @data instance variable is set, and contains a hash
    #   with a key matching the missing method, return the value from that hash key.
    #   Said value may be typecast into a Ruby object if the source XML is formatted
    #   properly. Otherwise returns nil.
    def method_missing(method)
      key = @data[method.to_s] if @data
      key
    end
  end
end

Dir["#{File.dirname(__FILE__)}/webbynode-api/*.rb"].each {|file| require file}