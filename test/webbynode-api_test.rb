require 'test_helper'

class WebbynodeApiTest < Test::Unit::TestCase
  context "fetching client data from API" do
    setup do
      email = "example@email.com"
      api_key = "123456"
      data_path = File.join(File.dirname(__FILE__), "data")
      FakeWeb.register_uri(:get, /https:\/\/manager\.webbynode\.com\/api\/xml\/client\?.+/i, :body => File.read("#{data_path}/api-xml-client.xml"))
      @api = WebbyNode::Client.new(email, api_key)
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
end
