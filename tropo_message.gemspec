# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tropo_message/version"

Gem::Specification.new do |s|
  s.name        = "tropo_message"
  s.version     = TropoMessage::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Wilkie"]
  s.email       = ["dwilkie@gmail.com"]
  s.homepage    = "https://github.com/dwilkie/tropo_message"
  s.summary     = %q{Simplifies sending messages with Tropo}
  s.description = %q{Makes it easier to send a message using Tropo}

  s.rubyforge_project = "tropo_message"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

