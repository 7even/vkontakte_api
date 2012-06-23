# encoding: utf-8
$: << File.expand_path('../lib', __FILE__)
require 'vkontakte_api/version'

Gem::Specification.new do |s|
  s.name        = 'vkontakte_api'
  s.version     = VkontakteApi::VERSION
  s.authors     = ['Vsevolod Romashov']
  s.email       = ['7@7vn.ru']
  s.homepage    = 'http://7even.github.com/vkontakte_api'
  s.summary     = %q{Ruby-way wrapper for VKontakte API}
  s.description = %q{A transparent wrapper for API of vk.com social network called VKontakte. Supports ruby-way method naming (without any method lists inside), result typecasting and any faraday-supported http adapter of your choice (no hardcoded Net::HTTP).}
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
  
  s.add_runtime_dependency 'activesupport', '~> 3.0'
  s.add_runtime_dependency 'i18n',          '~> 0.6'
  s.add_runtime_dependency 'faraday',       '~> 0.7.6'
  s.add_runtime_dependency 'yajl-ruby',     '~> 1.0'
  s.add_runtime_dependency 'hashie',        '~> 1.2'
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'awesome_print'
end
