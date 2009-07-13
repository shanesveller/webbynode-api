class WebbyNode
  # Represents the account-holder's information
  #
  # @author Shane Sveller
  # @since 0.0.1
  # @version 0.1.0
  class Client < WebbyNode::APIObject
    # Fills the @data variable with a hash of information about the client.
    #
    # @option options [String] :email E-mail address used for API access
    # @option options [String] :token API token used for API access
    # @example Get amount of credit left on an account
    #   @client = WebbyNode::Client.new(:email => email, :token)
    #   pp @client.credit # => 1.5
    def initialize(options = {})
      super(options)
      @data = auth_get("/api/xml/client")["hash"]["client"]
    end
  end

  # Represents an individual webby with status, reboot/shutdown/start functionality
  # via +method_missing+
  #
  # @author Shane Sveller
  # @since 0.0.1
  # @version 0.1.0
  class Webby < WebbyNode::APIObject
    attr_accessor :hostname

    # Fetches an individual Webby's data.
    #
    # @option options [String] :email E-mail address used for API access
    # @option options [String] :token API token used for API access
    # @option options [String] :hostname Hostname used to look up an individual
    #   Webby. When absent or nil, the newly instantiated object instead
    #   represents an Array of Webbies.
    # @example Fetch data for a Webby named "webby1"
    #   @webby = WebbyNode::Webby.new(:email => email, :token => token, "webby1")
    def initialize(options = {})
      raise ArgumentError, ":hostname is a required argument" unless options[:hostname]
      super(options)
      @hostname = options[:hostname]
    end

    # Provides status, start/shutdown/reboot functionality for an individual
    # Webby.
    def method_missing(method)
      if method.to_s == "status"
        return auth_get("/api/xml/webby/#{@hostname}/status")["hash"]["status"]
      elsif %w(start shutdown reboot).include? method.to_s
        return auth_get("/api/xml/webby/#{@hostname}/#{method.to_s}")["hash"]["job_id"]
      elsif method.to_s == "list"
        return @data
      else
        raise ArgumentError, "No such action possible on a Webby."
      end
    end
  end

  # Represents a list of all Webbies on an account
  #
  # @author Shane Sveller
  # @since 0.1.0
  # @version 0.1.0
  class WebbyList < WebbyNode::APIObject
    # Fetches an array of Webbies' data.
    #
    # @option options [String] :email E-mail address used for API access
    # @option options [String] :token API token used for API access
    # @example Fetch an Array of Webbies
    #   WebbyNode::Webby.new(:email => email, :token => token)
    def initialize(options = {})
      super(options)
      @data = auth_get("/api/xml/webbies")["hash"]["webbies"]
    end
  end
end
