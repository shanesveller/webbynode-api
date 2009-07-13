class WebbyNode
  class DNS
    # Represents the DNS zones present on the API account
    #
    # @author Shane Sveller
    # @since 0.0.2
    # @version 0.1.0
    class Zone < WebbyNode::APIObject
      # Holds the ID used internally at WebbyNode that represents a given zone.
      attr_accessor :id

      # Fetches either a single zone or an Array of all zones based on the presence
      # of the id parameter.
      #
      # @option options [String] :email E-mail address used for API access
      # @option options [String] :token API token used for API access
      # @option options [Integer] :id ID that represents an individual zone
      # @raise [ArgumentError] Raises ArgumentError if the :id option is missing
      #   from the optins parameter.
      # @example Get a zone with ID 100
      #   @zone = WebbyNode::DNS::Zone.new(:email => email, :token => token, :id => 100)
      def initialize(options = {})
        raise ArgumentError, ":id is a required argument" unless options[:id]
        super(options)
        @id = options[:id]
        @data = auth_get("/api/xml/dns/#{@id}")["hash"]["zone"]
      end

      # Activates a DNS zone in WebbyNode's DNS servers
      #
      # @since 0.1.2
      # @return [String] Returns "Active" if successful
      # @example Activate a zone with ID 100
      #   @zone = WebbyNode::DNS::Zone.new(:email => email, :token => token, :id => 100)
      #   @zone.status
      #   # => "Inactive"
      #   @zone.activate
      #   # => "Active"
      def activate
        status = auth_post("/api/xml/dns/#{@id}", {:query => {"zone[status]" => "Active", :email => @email, :token => @token}})["hash"]["status"]
        raise "Unable to activate zone" unless status == "Active"
        return status
      end

      # Activates a DNS zone in WebbyNode's DNS servers
      #
      # @since 0.1.2
      # @return [String] Returns "Inactive" if successful
      # @example Deactivate a zone with ID 100
      #   @zone = WebbyNode::DNS::Zone.new(:email => email, :token => token, :id => 100)
      #   @zone.status
      #   # => "Active"
      #   @zone.deactivate
      #   # => "Inactive"
      def deactivate
        status = auth_post("/api/xml/dns/#{@id}", {:query => {"zone[status]" => "Inactive", :email => @email, :token => @token}})["hash"]["status"]
        raise "Unable to deactivate zone" unless status == "Inactive"
        return status
      end

      # @since 0.0.6
      # @option options [String] :email E-mail address used for API access
      # @option options [String] :token API token used for API access
      # @option options [optional, String] :status Optional argument to set the
      #   status of the zone. Valid values include 'Active' or 'Inactive' only.
      # @return [Hash] Hash of the new zone's information
      # @raise [ArgumentError] Raises ArgumentError if :token, :email, :domain,
      #   or :ttl are missing from the options parameter.
      def self.create_zone(options = {})
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

    # Represents an Array of all DNS zones present on the API account
    #
    # @author Shane Sveller
    # @since 0.1.0
    # @version 0.1.0
    class ZoneList < WebbyNode::APIObject
      # Fetches an Array of all zones into @data.
      #
      # @option options [String] :email E-mail address used for API access
      # @option options [String] :token API token used for API access
      def initialize(options = {})
        super(options)
        @data = auth_get("/api/xml/dns")["hash"]["zones"]
      end
    end

    # Represents an Array of all DNS records for a given zone
    #
    # @author Shane Sveller
    # @since 0.1.1
    # @version 0.1.0
    class RecordList < WebbyNode::APIObject
      def initialize(options = {})
        raise ArgumentError, ":id is a required argument" unless options[:id]
        super(options)
        @id = options[:id]
        @data = auth_get("/api/xml/dns/#{@id}/records")["hash"]["records"]
      end
    end
  end
end