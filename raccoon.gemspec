# -*- encoding: utf-8 -*-
require File.expand_path('../lib/raccoon/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andreas Tiefenthaler"]
  gem.email         = ["at@an-ti.eu"]
  gem.description   = %q{Syslog jabber bot}
  gem.summary       = %q{Syslog jabber bot}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "raccoon"
  gem.require_paths = ["lib"]
  gem.version       = Raccoon::VERSION

  gem.add_dependency "celluloid-io"
  gem.add_dependency "xmpp4r"
end
