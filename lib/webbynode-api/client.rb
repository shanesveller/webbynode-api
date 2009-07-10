class WebbyNode
  class Client < WebbyNode::APIObject
    def initialize(email, api_key)
      super(email, api_key)
      @data = self.auth_get('/api/xml/client')["hash"]["client"]
    end
  end
end