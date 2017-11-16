$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name        = 'harbor'
  s.version     = Harbor::VERSION
  s.summary     = 'Harbor is a tool for you'
  s.description = 'Harbor tries to be a framework to manage internal infrastructure'
  s.authors     = ['Balazs Nadasdi']
  s.email       = 'balazs.nadasdi@cheppers.com'

  s.required_ruby_version = ::Gem::Requirement.new('>= 2.3')

  s.files       = Dir['README.md', 'lib/**/*.rb']
  s.executables = ['harbor', 'harbor-inventory']

  s.require_path = 'lib'

  s.homepage    = 'https://github.com/yitsushi/harbor'
  s.license     = 'MIT'

  s.add_dependency 'aws-sdk', '~> 3'
  s.add_dependency 'thor', '=0.20.0'
end

