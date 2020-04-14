# encoding: utf-8
$: << File.expand_path('../lib', __FILE__)
require 'vkontakte_api/version'

Gem::Specification.new do |s|
  s.name        = 'vkontakte_api'
  s.version     = VkontakteApi::VERSION
  s.authors     = ['Vsevolod Romashov']
  s.email       = ['7@7vn.ru']
  s.homepage    = 'http://7even.github.com/vkontakte_api'
  s.summary     = %q{Ruby wrapper for VKontakte API}
  s.description = %q{A transparent wrapper for VKontakte API. Supports ruby-way naming of API methods (without method lists inside), optional authorization, files uploading, logging and any faraday-supported http adapter of your choice.}
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.2'

  s.add_runtime_dependency 'faraday',                        '>= 0.9.0'
  s.add_runtime_dependency 'faraday_middleware',             '>= 0.9.1'
  unless defined?(JRUBY_VERSION)
    s.add_runtime_dependency 'oj',                           '>= 2.12'
  end
  s.add_runtime_dependency 'oauth2',                         '>= 0.8'
  s.add_runtime_dependency 'hashie',                         '>= 2.0'
  s.add_runtime_dependency 'multi_json',                     '>= 1.3'
  s.add_runtime_dependency 'faraday_middleware-multi_json',  '~> 0.0.6'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'mechanize'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rb-fsevent', '~> 0.9.1'
  s.add_development_dependency 'terminal-notifier'
  s.add_development_dependency 'terminal-notifier-guard'
  s.add_development_dependency 'colorize'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'awesome_print'

  unless defined?(JRUBY_VERSION)
    s.add_development_dependency 'yard'
    s.add_development_dependency 'redcarpet'
    s.add_development_dependency 'guard-yard'
  end
end
