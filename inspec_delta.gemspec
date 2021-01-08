# frozen_string_literal: true

require_relative 'lib/inspec_delta/version'

Gem::Specification.new do |spec|
  spec.name          = 'inspec_delta'
  spec.version       = InspecDelta::VERSION
  spec.required_ruby_version = '~> 2.7', '>= 2.7.1'
  spec.date          = '2020-09-21'
  spec.authors       = %w[JP024221]
  spec.email         = %w[jeremy.perron2@cerner.com]
  spec.bindir        = 'bin'
  spec.executables   = 'inspec_delta'
  spec.files         = Dir['lib/**/*.rb', 'README.md', 'bin/*']
  spec.require_paths = ['lib']
  spec.summary       = 'Quality of Life tools for managing inspec profiles.'
  spec.description   = 'Quality of Life tools for managing inspec profiles.'
  spec.homepage      = 'https://github.com/cerner/inspec_delta'
  spec.license       = 'APACHE'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'facets', '~> 3.1.0'
  spec.add_dependency 'inspec-objects', '~> 0.1.0'
  spec.add_dependency 'inspec_tools', '~> 2.2.0'
  spec.add_dependency 'ruby2ruby', '~> 2.4.4'
  spec.add_dependency 'ruby_parser', '~> 3.14.2'
  spec.add_dependency 'thor', '~> 1.0.1'
end
