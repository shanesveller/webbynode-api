class WebbyNode
  # Represents the account-holder's information
  class Client < WebbyNode::APIObject
    def initialize(email, api_key)
      super(email, api_key)
      @data = auth_get("/api/xml/client")["hash"]["client"]
    end
  end

  # Represents an individual webby with status, reboot/shutdown/start functionality
  # via +method_missing+
  class Webby < WebbyNode::APIObject
    attr_accessor :hostname

    # Optionally takes a hostname as the third argument to fetch just that Webby.
    # Leaving this nil set @data to an array of all the account's webbies
    def initialize(email, api_key, hostname = nil)
      super(email, api_key)
      if hostname
        @hostname = hostname
      else
        @data = auth_get("/api/xml/webbies")["hash"]["webbies"]
      end
    end

    def method_missing(method)
      if method.to_s == "status"
        return auth_get("/api/xml/webby/#{@hostname}/status")["hash"]["status"]
      elsif %w(start shutdown reboot).include? method.to_s
        return auth_get("/api/xml/webby/#{@hostname}/#{method.to_s}")["hash"]["job_id"]
      elsif method.to_s == "list"
        return @data
      else
        raise "No such action possible on a Webby."
      end
    end
  end

  class DNS < WebbyNode::APIObject
    attr_accessor :id

    # Optionally takes an ID as the third argument to fetch just that zone. Without,
    # you get an array of all zones.
    def initialize(email, api_key, id = nil)
      super(email, api_key)
      if id
        @id = id
        @data = auth_get("/api/xml/dns/#{@id}")["hash"]["zone"]
      else
        @data = auth_get("/api/xml/dns")["hash"]
      end
    end

    def records
      raise "This method should only be called on DNS instances with an id" unless @id
      auth_get("/api/xml/dns/#{@id}/records")["hash"]["records"]
    end

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

    def self.delete_zone(options = {})
      raise ArgumentError, "API access information via :email and :token are required arguments" unless options[:email] && options[:token]
      raise ArgumentError, ":id is a required argument" unless options[:id]
      return auth_post("/api/xml/dns/#{options[:id]}/delete", :query => options)["hash"]["success"]
    end
  end
end
