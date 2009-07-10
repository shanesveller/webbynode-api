class WebbyNode
  class Client < WebbyNode::APIObject
    def initialize(email, api_key)
      super(email, api_key)
      @data = auth_get("/api/xml/client")["hash"]["client"]
    end
  end

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
end