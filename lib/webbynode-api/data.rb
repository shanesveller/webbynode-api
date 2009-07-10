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

    def initialize(email, api_key, hostname)
      super(email, api_key)
      @hostname = hostname
    end

    def method_missing(method)
      if method.to_s == "status"
        return auth_get("/api/xml/webby/#{@hostname}/status")["hash"]["status"]
      elsif %w(start shutdown reboot).include? method.to_s
        return auth_get("/api/xml/webby/#{@hostname}/#{method.to_s}")["hash"]["job_id"]
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
      raise "This method should only be called on DNS instances with an id." unless @id
      auth_get("/api/xml/dns/#{@id}/records")["hash"]["records"]
    end
  end
end