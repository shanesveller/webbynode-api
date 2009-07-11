# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{webbynode-api}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Sveller"]
  s.date = %q{2009-07-11}
  s.email = %q{shanesveller@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/webbynode-api.rb",
     "lib/webbynode-api/data.rb",
     "test/data/bad-auth.xml",
     "test/data/client.xml",
     "test/data/dns-1.xml",
     "test/data/dns-records.xml",
     "test/data/dns.xml",
     "test/data/webbies.xml",
     "test/data/webby-reboot.xml",
     "test/data/webby-shutdown.xml",
     "test/data/webby-start.xml",
     "test/data/webby-status-off.xml",
     "test/data/webby-status-reboot.xml",
     "test/data/webby-status-shutdown.xml",
     "test/data/webby-status.xml",
     "test/test_helper.rb",
     "test/webbynode-api_test.rb",
     "webbynode-api.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/shanesveller/webbynode-api}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{wraps the WebbyNode API into nice Ruby objects}
  s.test_files = [
    "test/test_helper.rb",
     "test/webbynode-api_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
