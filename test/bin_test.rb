require 'test_helper'

class WebbyNodeAPIObjectTest < Test::Unit::TestCase
  context "using the commandline tool" do
    context "when listing webbies" do
      setup do
        @input = "-a webby list"
        bin_path = File.join(File.dirname(__FILE__), '..', 'bin', 'webby')
        @output = `#{bin_path} #{@input}`
      end
    end
  end
end