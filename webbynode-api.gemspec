# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{webbynode-api}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Sveller"]
  s.date = %q{2009-07-14}
  s.default_executable = %q{webby}
  s.email = %q{shanesveller@gmail.com}
  s.executables = ["webby"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "bin/webby",
     "lib/webbynode-api.rb",
     "lib/webbynode-api/data.rb",
     "lib/webbynode-api/dns.rb",
     "test/apiobject_test.rb",
     "test/client_test.rb",
     "test/data/activate-zone.xml",
     "test/data/bad-auth.xml",
     "test/data/client.xml",
     "test/data/deactivate-zone.xml",
     "test/data/delete-record.xml",
     "test/data/delete-zone.xml",
     "test/data/dns-1.xml",
     "test/data/dns-records.xml",
     "test/data/dns.xml",
     "test/data/new-record.xml",
     "test/data/new-zone.xml",
     "test/data/webbies.xml",
     "test/data/webby-reboot.xml",
     "test/data/webby-shutdown.xml",
     "test/data/webby-start.xml",
     "test/data/webby-status-off.xml",
     "test/data/webby-status-reboot.xml",
     "test/data/webby-status-shutdown.xml",
     "test/data/webby-status.xml",
     "test/dns_test.rb",
     "test/test_helper.rb",
     "test/webby_test.rb",
     "webbynode-api.gemspec"
  ]
  s.homepage = %q{http://github.com/shanesveller/webbynode-api}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{wraps the WebbyNode API into nice Ruby objects}
  s.test_files = [
    "test/test_helper.rb",
     "test/webby_test.rb",
     "test/dns_test.rb",
     "test/client_test.rb",
     "test/apiobject_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.3"])
      s.add_runtime_dependency(%q<optiflag>, [">= 0.6.5"])
    else
      s.add_dependency(%q<httparty>, [">= 0.4.3"])
      s.add_dependency(%q<optiflag>, [">= 0.6.5"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0.4.3"])
    s.add_dependency(%q<optiflag>, [">= 0.6.5"])
  end
end
