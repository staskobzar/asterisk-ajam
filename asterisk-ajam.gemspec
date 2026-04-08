lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asterisk/ajam/version'

Gem::Specification.new do |spec|
  spec.name          = 'asterisk-ajam'
  spec.version       = Asterisk::AJAM::VERSION
  spec.authors       = ['Stas Kobzar']
  spec.email         = ['staskobzar@gmail.com']
  spec.description   = 'Ruby module for interacting with Asterisk management interface (AMI) via HTTP'
  spec.summary       = 'AMI via HTTP'
  spec.homepage      = 'https://github.com/staskobzar/asterisk-ajam'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'rspec'
  spec.add_runtime_dependency 'libxml-ruby'
end
