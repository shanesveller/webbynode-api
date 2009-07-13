require 'test_helper'

class WebbynodeApiTest < Test::Unit::TestCase
  context "with bad API token or email" do
    setup do
      @email ="example@email.com"
      @token = "123456"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/client\?\w+/i, :body => File.read("#{data_path}/bad-auth.xml"))
      FakeWeb.register_uri(:post, /^https:\/\/manager\.webbynode\.com\/.+$/, :body => "")
    end
    should "raise ArgumentError if no API data given" do
      # for auth_get
      assert_raise(ArgumentError, "API information is missing or incomplete"){ WebbyNode::Client.new(:email => nil, :token => nil) }
      assert_raise(ArgumentError, "API information is missing or incomplete"){ WebbyNode::Client.new(:email => @email, :token => nil) }
      assert_raise(ArgumentError, "API information is missing or incomplete"){ WebbyNode::Client.new(:email => nil, :token => @token) }
      # for auth_post
      assert_raise(ArgumentError, "API information is missing or incomplete"){ WebbyNode::APIObject.new(:email => nil, :token => nil).auth_post("",{}) }
      assert_raise(ArgumentError, "API information is missing or incomplete"){ WebbyNode::APIObject.new(:email => @email, :token => nil).auth_post("",{}) }
      assert_raise(ArgumentError, "API information is missing or incomplete"){ WebbyNode::APIObject.new(:email => nil, :token => @token).auth_post("",{}) }
    end
    should "raise ArgumentError if bad API data given" do
      assert_raise(ArgumentError, "Probable bad API information given"){ WebbyNode::Client.new(@email, @token) }
      # TODO: Need XML fixture file for this
      # assert_raise(ArgumentError, "Probable bad API information given"){ WebbyNode::APIObject.new(@email, @token).auth_post("",{}) }
    end
  end
  context "fetching client data from API" do
    setup do
      email = "example@email.com"
      token = "123456"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/client\?.+/i, :body => File.read("#{data_path}/client.xml"))
      @api = WebbyNode::Client.new(:email => email, :token => token)
    end

    should "use method missing to get values for present keys" do
      @api.methods.include?("firstname").should == false
      @api.firstname.should == "Shane"
    end

    should "return nil for missing keys" do
      @api.blank.should be(nil)
    end

    should "fetch physical address information" do
      @api.address1.should == "1234 Nonexistent Lane"
      @api.city.should == "Nameless City"
      @api.postcode.should == "65432"
      @api.state.should == "My State"
      @api.country.should == "US"
    end

    should "fetch user name, email and status" do
      @api.firstname.should == "Shane"
      @api.lastname.should == "Sveller"
      @api.email.should == "example@email.com"
      @api.status.should == "Active"
      @api.datecreated.should == Date.new(2009,06,30)
    end

    should "fetch company name, phone number and credits" do
      @api.credit.should == 1.5
      @api.companyname.should == "Phantom Inc."
      @api.phonenumber.should == "555-867-5309"
    end
  end

  context "fetching webby data from API" do
    setup do
      email = "example@email.com"
      token = "123456"
      hostname = "webby1"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/start\?.+/i, :body => File.read("#{data_path}/webby-start.xml"))
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/shutdown\?.+/i, :body => File.read("#{data_path}/webby-shutdown.xml"))
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/reboot\?.+/i, :body => File.read("#{data_path}/webby-reboot.xml"))
      @webby = WebbyNode::Webby.new(:email => email, :token => token, :hostname => hostname)
    end
    should "return a job ID when starting, shutting down, or rebooting" do
      @webby.start.should == 2562
      @webby.shutdown.should == 2561
      @webby.reboot.should == 2564
    end
    should "return a valid status" do
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/status\?.+/i, :body => File.read("#{data_path}/webby-status.xml"))
      @webby.status.should == "on"
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/status\?.+/i, :body => File.read("#{data_path}/webby-status-shutdown.xml"))
      @webby.status.should == "Shutting down"
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/status\?.+/i, :body => File.read("#{data_path}/webby-status-off.xml"))
      @webby.status.should == "off"
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/status\?.+/i, :body => File.read("#{data_path}/webby-status-reboot.xml"))
      @webby.status.should == "Rebooting"
    end
  end
  context "fetching webbies data from API" do
    setup do
      email = "example@email.com"
      token = "123456"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/webbies\?.+/i, :body => File.read("#{data_path}/webbies.xml"))
      @webbies = WebbyNode::WebbyList.new(:email => email, :token => token)
    end
    should "return a array of webbies" do
      @webbies.data.is_a?(Array).should be(true)
      webby = @webbies.data.first
      webby["status"].should == "on"
      webby["ip"].should == "222.111.222.111"
      webby["node"].should == "location-a01"
      webby["plan"].should == "Webby_384"
      webby["name"].should == "webby1"
      webby["notes"].should be(nil)
    end
  end

  context "fetching DNS data from API without id" do
    setup do
      email = "example@email.com"
      token = "123456"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\?.+/i, :body => File.read("#{data_path}/dns.xml"))
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/dns-1.xml"))
      @dns = WebbyNode::DNS.new(:email => email, :token => token)
    end
    should "return an array of zones with domain, status, id, and TTL" do
      @dns.zones.is_a?(Array).should be(true)
      @dns.zones.size.should == 3
      zone = @dns.zones.first
      zone["id"].should == 1
      zone["status"].should == "Active"
      zone["domain"].should == "example.com."
      zone["ttl"].should == 86400
      zone = @dns.zones.last
      zone["id"].should == 132
      zone["status"].should == "Inactive"
      zone["domain"].should == "inactive.com."
      zone["ttl"].should == 86400
    end
  end
  context "fetching DNS data from API with id" do
    setup do
      email = "example@email.com"
      token = "123456"
      id = 1
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\?.+/i, :body => File.read("#{data_path}/dns.xml"))
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/dns-1.xml"))
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\/records\?.+/i, :body => File.read("#{data_path}/dns-records.xml"))
      @dns = WebbyNode::DNS.new(:email => email, :token => token, :id => id)
    end
    should "return domain name, status, id and TTL" do
      @dns.domain.should == "example.com."
      @dns.id.should == 1
      @dns.ttl.should == 86400
      @dns.status.should == "Active"
    end
    should "return an array of records with id, type, name, data, auxiliary data, and TTL" do
      @dns.records.is_a?(Array).should be(true)
      record = @dns.records.first
      record["id"].should == 51
      record["ttl"].should == 86400
      record["data"].should == "200.100.200.100"
      record["name"].should be(nil)
      record["aux"].should == 0
      record["type"].should == "A"
    end
  end
  context "creating a new DNS zone" do
    setup do
      @email = "example@email.com"
      @token = "123456"
      @domain = "example.com."
      @ttl = 86400
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:post, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/new\?.+/i, :body => File.read("#{data_path}/new-zone.xml"))
    end
    should "raise ArgumentError if API information isn't present" do
      assert_raise(ArgumentError,"API access information via :email and :token are required arguments"){ WebbyNode::DNS.new_zone(:token => @token, :domain => @domain, :ttl => @ttl) }
      assert_raise(ArgumentError,"API access information via :email and :token are required arguments"){ WebbyNode::DNS.new_zone(:email => @email, :domain => @domain, :ttl => @ttl) }
    end
    should "raise ArgumentError if :domain or :ttl aren't included in method call" do
      assert_raise(ArgumentError, ":domain and :ttl are required arguments"){ WebbyNode::DNS.new_zone(:email => @email, :token => @token, :ttl => @ttl) }
      assert_raise(ArgumentError, ":domain and :ttl are required arguments"){ WebbyNode::DNS.new_zone(:email => @email, :token => @token, :domain => @domain) }
    end
    should "raise ArgumentError if :status is not a valid option" do
      assert_raise(ArgumentError, ":domain and :ttl are required arguments"){ WebbyNode::DNS.new_zone(:email => @email, :token => @token, :ttl => @ttl, :status => "Not active") }
      assert_nothing_raised(ArgumentError){ WebbyNode::DNS.new_zone(:email => @email, :token => @token, :domain => @domain, :ttl => @ttl, :status => "Active") }
      assert_nothing_raised(ArgumentError){ WebbyNode::DNS.new_zone(:email => @email, :token => @token, :domain => @domain, :ttl => @ttl, :status => "Inactive") }
      assert_nothing_raised(ArgumentError){ WebbyNode::DNS.new_zone(:email => @email, :token => @token, :domain => @domain, :ttl => @ttl, :status => nil) }
    end
    should "return a Hash containing the new zone's information" do
      @new_zone =  WebbyNode::DNS.new_zone(:email => @email, :token => @token, :domain => @domain, :ttl => @ttl, :status => "Inactive")
      @new_zone["id"].should == 171
      @new_zone["domain"].should == "example.com."
      @new_zone["ttl"].should == 86400
    end
  end
  context "deleting a DNS zone" do
    setup do
      @email = "example@email.com"
      @token = "123456"
      @id = 171
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:post, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\/delete\?.+/i, :body => File.read("#{data_path}/delete-zone.xml"))
    end
    should "return a boolean true for succesful deletion" do
      WebbyNode::DNS.delete_zone(:email => @email, :token => @token, :id => @id)
    end
  end
end
