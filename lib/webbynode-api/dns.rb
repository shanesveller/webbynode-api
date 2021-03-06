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

      # Edits attributes of an existing DNS zone
      #
      # @option new_values [optional, String] :domain Domain name for the DNS zone
      # @option new_values [optional, Integer] :ttl Time To Live for the DNS zone
      # @option new_values [optional, String] :status Whether or not to serve the zone.
      #   Valid values are Active or Inactive.
      # @raise [ArgumentError] Raises ArgumentError if an invalid value is passed for
      #   :status.
      # @return [Hash] returns a Hash with String keys of the newly-edited zone's data
      # @example Change a zone's TTL
      #   @zone = WebbyNode::DNS::Zone.new(:email => @email, :token => @token, :id => @id)
      #   @zone.ttl # => 86400
      #   @zone.edit(:ttl => 14400)
      #   @zone.ttl # => 14400
      # @example Change a zone's domain name, TTL and activate it
      #   @zone = WebbyNode::DNS::Zone.new(:email => @email, :token => @token, :id => @id)
      #   @zone.edit(:domain => "newurl.com.", :status => "Active", :ttl => 86600)
      def edit(new_values = {})
        if new_values[:status]
          raise ArgumentError, ":status must be Active or Inactive" unless %w(Active Inactive).include?(new_values[:status])
        end
        new_values.reject! {|key, value| %w(domain ttl status).include?(key) == false }
        for key in new_values.keys
          new_values["zone[#{key.to_s}]"] = new_values[key]
          new_values.delete(key)
        end
        new_values.merge!(:email => @email, :token => @token)
        @data = self.class.auth_post("/api/xml/dns/#{@id}", :query => new_values)["hash"]
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
      # @example Create a zone with the domain example.com and TTL of 86400
      #   WebbyNode::DNS::Zone.create_zone({
      #     :email => email, :token => token,
      #     :domain => "example.com.", :ttl => 86400
      #   })
      # @example Create an *inactive* zone with the domain example.com and TTL of 86400
      #   WebbyNode::DNS::Zone.create_zone({
      #     :email => email, :token => token,
      #     :domain => "example.com.", :ttl => 86400,
      #     :status => "Inactive"
      #   })
      def self.create_zone(options = {})
        raise ArgumentError, ":email and :token are required arguments for API access" unless options[:email] && options[:token]
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
      #   missing from the options parameter.
      # @example Delete a zone with ID of 100
      #   WebbyNode::DNS::Zone.delete_zone({
      #     :email => email, :token => token,
      #     :id => 100
      #   })
      #   # => true
      def self.delete_zone(options = {})
        raise ArgumentError, ":email and :token are required arguments for API access" unless options[:email] && options[:token]
        raise ArgumentError, ":id is a required argument" unless options[:id]
        return auth_post("/api/xml/dns/#{options[:id]}/delete", :query => options)["hash"]["success"]
      end

      # @since 0.2.5
      # @option options [String] :email E-mail address used for API access
      # @option options [String] :token API token used for API access
      # @option options [String] :domain Domain name to search for
      # @return [Hash, nil] Returns a hash of data about the zone if it exists
      #   or nil
      # @raise [ArgumentError] Raises ArgumentError if :token, :email or :domain
      #   are missing from the options parameter
      # @example Look up a zone for the domain "example.com." (Note the final period.)
      #   WebbyNode::DNS::Zone.find_by_domain(:email => @email, :token => @token,
      #   :domain => "example.com.")
      def self.find_by_domain(options = {})
        raise ArgumentError, ":domain is a required argument" unless options[:domain]
        domain = options[:domain]
        all_zones = ZoneList.new(:email => options[:email], :token => options[:token])
        all_zones.data.reject! {|zone| zone["domain"] != domain}
        return all_zones.data.first || nil
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
      # Fills the @data variable with an Array of Hashes containing individual
      # DNS records in a zone.
      #
      # @option options [String] :email E-mail address used for API access
      # @option options [String] :token API token used for API access
      # @option options [Integer] :id ID used internally by WebbyNode to identify the zone
      # @raise [ArgumentError] Raises ArgumentError if :email, :token, or :id are absent from options
      def initialize(options = {})
        raise ArgumentError, ":id is a required argument" unless options[:id]
        super(options)
        @id = options[:id]
        @data = auth_get("/api/xml/dns/#{@id}/records")["hash"]["records"]
      end
    end

    # Represents a single DNS record
    #
    # @author Shane Sveller
    # @since 0.1.3
    # @version 0.1.0
    class Record < WebbyNode::APIObject
      def initialize(options = {})
        raise ArgumentError, ":id is a required argument" unless options[:id]
        super(options)
        @id = options[:id]
        @data = auth_get("/api/xml/records/#{@id}")["hash"]["record"]
      end

      # Creates a new DNS record
      #
      # @option options [String] :email E-mail address used for API access
      # @option options [String] :token API token used for API access
      # @option options [String] :type DNS record type i.e. A, CNAME or MX
      # @option options [String] :data DNS record data, typically an IP address
      def self.create(options = {})
        raise ArgumentError, ":email and :token are required arguments for API access" unless options[:email] && options[:token]
        raise ArgumentError, ":data and :type are required arguments" unless options[:data] && options[:type]
        valid_types = %w(A CNAME MX)
        raise ArgumentError, "#{options[:type]} is not a valid value for :type" unless valid_types.include?(options[:type])
        @id = options[:id]
        options.delete(:id)
        for key in options.keys
          if %w(type name data aux ttl).include? key.to_s
            options["record[#{key.to_s}]"] = options[key]
            options.delete(key)
          end
        end
        return auth_post("/api/xml/dns/#{@id}/records/new", :query => options)["hash"]["record"]
      end

      # Deletes an existing DNS record by ID
      #
      # @since 0.2.1
      # @option options [String] :email E-mail address used for API access
      # @option options [String] :token API token used for API access
      # @option options [Integer] :id WebbyNode's internally-used ID that idenftifies the record
      # @return [Boolean] Returns true upon succesful deletion of the zone.
      # @raise [ArgumentError] Raises ArgumentError if :token, :email, or :id are
      #   missing from the options parameter.
      # @example Delete a DNS record with ID of 100
      #   WebbyNode::DNS::Record.delete({
      #     :email => email, :token => token,
      #     :id => 100
      #   })
      #   # => true
      def self.delete(options = {})
        raise ArgumentError, ":email and :token are required arguments for API access" unless options[:email] && options[:token]
        raise ArgumentError, ":id is a required argument" unless options[:id]
        return auth_post("/api/xml/records/#{options[:id]}/delete", :query => options)["hash"]["success"]
      end
    end
  end
end