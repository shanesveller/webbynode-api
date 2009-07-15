require 'test_helper'

class WebbyNodeAPIObjectTest < Test::Unit::TestCase
  context "when fetching an API object" do
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
end