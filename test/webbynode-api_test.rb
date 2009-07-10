require 'test_helper'

class WebbynodeApiTest < Test::Unit::TestCase
  context "fetching client data from API" do
    setup do
      email = "example@email.com"
      api_key = "123456"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/client\?.+/i, :body => File.read("#{data_path}/client.xml"))
      @api = WebbyNode::Client.new(email, api_key)
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

  context "fetching webbies data from API" do
    setup do
      email = "example@email.com"
      api_key = "123456"
      hostname = "webby1"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/start\?.+/i, :body => File.read("#{data_path}/webby-start.xml"))
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/shutdown\?.+/i, :body => File.read("#{data_path}/webby-shutdown.xml"))
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/reboot\?.+/i, :body => File.read("#{data_path}/webby-reboot.xml"))
      @webby = WebbyNode::Webby.new(email, api_key, hostname)
    end
    should "return a job ID when starting, shutting down, or rebooting" do
      @webby.start.should == 2562
      @webby.shutdown.should == 2561
      @webby.reboot.should == 2564
    end
    should "return a valid status" do
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/status\?.+/i, :body => File.read("#{data_path}/webby-status.xml"))
      @webby.status.should == "on"
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/status\?.+/i, :body => File.read("#{data_path}/webby-status-shutdown.xml"))
      @webby.status.should == "Shutting down"
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/status\?.+/i, :body => File.read("#{data_path}/webby-status-off.xml"))
      @webby.status.should == "off"
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/webby\/\w+\/status\?.+/i, :body => File.read("#{data_path}/webby-status-reboot.xml"))
      @webby.status.should == "Rebooting"
    end
  end
end
