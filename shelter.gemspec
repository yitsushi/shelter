$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name        = 'shelter'
  s.version     = Shelter::VERSION
  s.summary     = 'Shelter is a tool for you'
  s.description = 'Shelter tries to be a framework to manage internal infrastructure'
  s.authors     = ['Balazs Nadasdi']
  s.email       = 'balazs.nadasdi@cheppers.com'

  s.required_ruby_version = ::Gem::Requirement.new('>= 2.3')

  s.files       = Dir['*.md', 'lib/**/*.rb']
  s.executables = ['shelter', 'shelter-inventory']

  s.require_path = 'lib'

  s.homepage    = 'https://github.com/yitsushi/shelter'
  s.license     = 'MIT'

  s.extra_rdoc_files = Dir['*.md']
  s.rdoc_options = [
    '--main', 'README.md',
    '--line-numbers',
    '--all'
  ]

  s.add_dependency 'aws-sdk', '~> 3'
  s.add_dependency 'thor', '=0.20.0'

  s.add_development_dependency 'rake', '>= 12.0'
  s.add_development_dependency 'rdoc', '>= 5.1'
  s.add_development_dependency 'rubocop', '>= 0.48'
end

