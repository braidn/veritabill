# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Prior Knowledge"]
  gem.email         = ["support@priorknowledge.com"]
  gem.description   = "Veritabill is a minimal Sinatra app demonstrating integration with Veritable, the predictive database developed by Prior Knowledge (http://www.priorknowledge.com)"
  gem.summary       = "A minimal Sinatra reference design for Veritable integration"
  gem.homepage      = "https://dev.priorknowledge.com"

  gem.files         = Dir["**/*"].select { |d| d =~ %r{^(README.md|LICENSE|CHANGELOG.txt|lib/|public/|test/)} }
  gem.name          = "veritabill"
  gem.require_paths = %w{lib}
  gem.version       = "0.1.0"
  
  gem.add_dependency('sinatra')
  gem.add_dependency('activerecord')
  gem.add_dependency('uri')
  gem.add_development_dependency('test-unit')
  gem.add_development_dependency('rack-test')
end
