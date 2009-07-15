require 'rubygems'
require 'test/unit'
%w(shoulda matchy fakeweb monkeyspecdoc pp).each {|x| require x }

FakeWeb.allow_net_connect = false

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'webbynode-api'

class Test::Unit::TestCase
end
