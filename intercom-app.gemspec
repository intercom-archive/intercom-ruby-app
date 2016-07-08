lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'intercom-app/version'

Gem::Specification.new do |s|
  s.name        = 'intercom-app'
  s.version     = IntercomApp::VERSION
  s.date        = '2016-07-04'
  s.summary     = "Intercom.io ruby application boilerplate"
  s.description = "This gem helps you to get started with your Intercom.io app"
  s.authors     = ["Kevin Antoine"]
  s.email       = 'kevin.antoine@intercom.io'
  s.files       = ["lib/intercom-app.rb"]
  s.homepage    =
    'http://rubygems.org/gems/intercom-ruby-app'
  s.license       = 'MIT'
  s.require_paths = ["lib"]
  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  s.add_runtime_dependency 'intercom', '~>3.5'
  s.add_runtime_dependency 'omniauth-intercom', '~>0.1'

  s.add_development_dependency 'rails', '~> 4.2'
  s.add_development_dependency 'sqlite3', '~> 0'
  s.add_development_dependency 'mocha', '~> 0'
  s.add_development_dependency 'byebug', '~> 0'
  s.add_development_dependency 'bundler', '~> 1.12'
  s.add_development_dependency 'rake', '~> 10.0'
end
