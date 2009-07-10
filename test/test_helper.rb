require 'rubygems'
require 'test/unit'
require 'shoulda'
%w(matchy fakeweb pp).each {|x| require x }

FakeWeb.allow_net_connect = false

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'webbynode-api'

class Test::Unit::TestCase
end
