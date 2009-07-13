require 'test_helper'

class WebbyNodeWebbyTest < Test::Unit::TestCase
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
end