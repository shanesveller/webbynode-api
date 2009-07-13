class WebbyNode
  # Represents the account-holder's information
  #
  # @author Shane Sveller
  # @since 0.0.1
  class Client < WebbyNode::APIObject
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
  class Webby < WebbyNode::APIObject
    attr_accessor :hostname

    # Fetches either an array of Webbies' data or an individual Webby's data.
    #
    # @param [String] email E-mail address used for API access
    # @param [String] api_key API token used for API access
    # @param [optional, String] hostname Hostname used to look up an individual
    #   Webby. When absent or nil, the newly instantiated object instead
    #   represents an Array of Webbies.
    # @example Fetch data for a Webby named "webby1"
    #   WebbyNode::Webby.new(email, api_key, "webby1")
    # @example Fetch an Array of Webbies
    #   WebbyNode::Webby.new(email, api_key)
    def initialize(options = {})
      super(options)
      if options[:hostname]
        @hostname = options[:hostname]
      else
        @data = auth_get("/api/xml/webbies")["hash"]["webbies"]
      end
    end

    # Provides status, start/shutdown/reboot functionality for an individual
    # Webby. Provides list functionality for an Array of Webbies.
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

  # Represents the DNS zones present on the API account
  #
  # @author Shane Sveller
  # @since 0.0.2
  class DNS < WebbyNode::APIObject
    # Holds the ID used internally at WebbyNode that represents a given zone.
    attr_accessor :id

    # Fetches either a single zone or an Array of all zones based on the presence
    # of the id parameter.
    #
    # @param [String] email E-mail address used for API access
    # @param [String] api_key API token used for API access
    # @param [option, Integer] id ID that represents an individual zone
    def initialize(options = {})
      super(options)
      if options[:id]
        @id = options[:id]
        @data = auth_get("/api/xml/dns/#{@id}")["hash"]["zone"]
      else
        @data = auth_get("/api/xml/dns")["hash"]
      end
    end

    # @since 0.0.3
    # @return [Array<Hash>] Array of a zones' records, each individually is a Hash.
    def records
      raise "This method should only be called on DNS instances with an id" unless @id
      auth_get("/api/xml/dns/#{@id}/records")["hash"]["records"]
    end

    # @since 0.0.6
    # @option options [String] :email E-mail address used for API access
    # @option options [String] :token API token used for API access
    # @option options [optional, String] :status Optional argument to set the
    #   status of the zone. Valid values include 'Active' or 'Inactive' only.
    # @return [Hash] Hash of the new zone's information
    # @raise [ArgumentError] Raises ArgumentError if :token, :email, :domain,
    #   or :ttl are missing from the options parameter.
    def self.new_zone(options = {})
      raise ArgumentError, "API access information via :email and :token are required arguments" unless options[:email] && options[:token]
      raise ArgumentError, ":domain and :ttl are required arguments" unless options[:domain] && options[:ttl]
      if options[:status]
        raise ArgumentError, ":status must be 'Active' or 'Inactive'" unless %w(Active Inactive).include? options[:status]
      end
      zone_data = auth_post("/api/xml/dns/new", :query =>
        {
          :email => options[:email],
          :token => options[:token],
          "zone[domain]" => options[:domain],
          "zone[ttl]" => options[:ttl],
          "zone[status]" => options[:status]
        })
      return zone_data["hash"]
    end

    # @since 0.0.6
    # @option options [String] :email E-mail address used for API access
    # @option options [String] :token API token used for API access
    # @option options [Integer] :id WebbyNode's internally-used ID that idenftifies the zone
    # @return [Boolean] Returns true upon succesful deletion of the zone.
    # @raise [ArgumentError] Raises ArgumentError if :token, :email, or :id are
    # missing from the options parameter.
    def self.delete_zone(options = {})
      raise ArgumentError, "API access information via :email and :token are required arguments" unless options[:email] && options[:token]
      raise ArgumentError, ":id is a required argument" unless options[:id]
      return auth_post("/api/xml/dns/#{options[:id]}/delete", :query => options)["hash"]["success"]
    end
  end
end
