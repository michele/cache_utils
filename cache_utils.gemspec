# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cache_utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'cache_utils'
  spec.version       = CacheUtils::VERSION
  spec.authors       = ['Michele Finotto']
  spec.email         = ['m@finotto.org']

  spec.summary       = 'Caching utilities built on top of Rails caching'
  spec.description   = 'Caching utilities built on top of Rails caching'
  spec.homepage      = 'https://github.com/michele/cache_utils'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_dependency 'rails', '> 4'
end
