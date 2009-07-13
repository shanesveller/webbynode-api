require 'test_helper'

class WebbyNodeDNSTest < Test::Unit::TestCase
  context "fetching all DNS data from API" do
    setup do
      email = "example@email.com"
      token = "123456"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\?.+/i, :body => File.read("#{data_path}/dns.xml"))
      @zones = WebbyNode::DNS::ZoneList.new(:email => email, :token => token)
    end
    should "return an array of zones with domain, status, id, and TTL" do
      @zones.data.is_a?(Array).should be(true)
      @zones.data.size.should == 3
      zone = @zones.data.first
      zone["id"].should == 1
      zone["status"].should == "Active"
      zone["domain"].should == "example.com."
      zone["ttl"].should == 86400
      zone = @zones.data.last
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
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/dns-1.xml"))
      @dns = WebbyNode::DNS::Zone.new(:email => email, :token => token, :id => id)
    end
    should "return domain name, status, id and TTL" do
      @dns.domain.should == "example.com."
      @dns.id.should == 1
      @dns.ttl.should == 86400
      @dns.status.should == "Active"
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
      assert_raise(ArgumentError,"API access information via :email and :token are required arguments"){ WebbyNode::DNS::Zone.create_zone(:token => @token, :domain => @domain, :ttl => @ttl) }
      assert_raise(ArgumentError,"API access information via :email and :token are required arguments"){ WebbyNode::DNS::Zone.create_zone(:email => @email, :domain => @domain, :ttl => @ttl) }
    end
    should "raise ArgumentError if :domain or :ttl aren't included in method call" do
      assert_raise(ArgumentError, ":domain and :ttl are required arguments"){ WebbyNode::DNS::Zone.create_zone(:email => @email, :token => @token, :ttl => @ttl) }
      assert_raise(ArgumentError, ":domain and :ttl are required arguments"){ WebbyNode::DNS::Zone.create_zone(:email => @email, :token => @token, :domain => @domain) }
    end
    should "raise ArgumentError if :status is not a valid option" do
      assert_raise(ArgumentError, ":domain and :ttl are required arguments"){ WebbyNode::DNS::Zone.create_zone(:email => @email, :token => @token, :ttl => @ttl, :status => "Not active") }
      assert_nothing_raised(ArgumentError){ WebbyNode::DNS::Zone.create_zone(:email => @email, :token => @token, :domain => @domain, :ttl => @ttl, :status => "Active") }
      assert_nothing_raised(ArgumentError){ WebbyNode::DNS::Zone.create_zone(:email => @email, :token => @token, :domain => @domain, :ttl => @ttl, :status => "Inactive") }
      assert_nothing_raised(ArgumentError){ WebbyNode::DNS::Zone.create_zone(:email => @email, :token => @token, :domain => @domain, :ttl => @ttl, :status => nil) }
    end
    should "return a Hash containing the new zone's information" do
      @new_zone =  WebbyNode::DNS::Zone.create_zone(:email => @email, :token => @token, :domain => @domain, :ttl => @ttl, :status => "Inactive")
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
      WebbyNode::DNS::Zone.delete_zone(:email => @email, :token => @token, :id => @id)
    end
  end
  context "activating and deactivating a zone" do
    setup do
      @email = "example@email.com"
      @token = "123456"
      @id = 171
    end
    should "raise RuntimeError if the action is unsuccesful" do
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/dns-1.xml"))
      FakeWeb.register_uri(:post, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/deactivate-zone.xml"))
      assert_raise(RuntimeError, "Unable to activate zone"){ WebbyNode::DNS::Zone.new(:email => @email, :token => @token, :id => @id).activate }
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/dns-1.xml"))
      FakeWeb.register_uri(:post, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/activate-zone.xml"))
      assert_raise(RuntimeError, "Unable to deactivate zone"){ WebbyNode::DNS::Zone.new(:email => @email, :token => @token, :id => @id).deactivate }
    end
    should "return the new status when activating or deactivating" do
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/dns-1.xml"))
      FakeWeb.register_uri(:post, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/activate-zone.xml"))
      WebbyNode::DNS::Zone.new(:email => @email, :token => @token, :id => @id).activate.should == "Active"
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/dns-1.xml"))
      FakeWeb.register_uri(:post, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\?.+/i, :body => File.read("#{data_path}/deactivate-zone.xml"))
      WebbyNode::DNS::Zone.new(:email => @email, :token => @token, :id => @id).deactivate.should == "Inactive"
    end
  end
  context "listing a DNS zone's records" do
    setup do
      @email = "example@email.com"
      @token = "123456"
      @id = 1
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.clean_registry
      FakeWeb.register_uri(:get, /^https:\/\/manager\.webbynode\.com\/api\/xml\/dns\/\d+\/records\?.+/i, :body => File.read("#{data_path}/dns-records.xml"))
    end
    should "raise ArgumentError if :id argument is absent" do
      assert_raise(ArgumentError, ":id is a required argument"){ WebbyNode::DNS::RecordList.new(:email => @email, :token => @token, :id => nil)}
      assert_nothing_raised { WebbyNode::DNS::RecordList.new(:email => @email, :token => @token, :id => @id)}
    end
    should "set @data to an Array of records" do
      @records = WebbyNode::DNS::RecordList.new(:email => @email, :token => @token, :id => @id)
      @records.data.is_a?(Array).should be(true)
      record = @records.data.first
      record["id"].should == 51
      record["ttl"].should == 86400
      record["data"].should == "200.100.200.100"
      record["name"].should be(nil)
      record["aux"].should == 0
      record["type"].should == "A"
    end
  end
end