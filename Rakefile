require 'bundler/gem_tasks'

desc 'Fires up the console with preloaded vkontakte_api'
task :console do
  sh 'pry -I ./lib -r ./lib/vkontakte_api'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '--color --format doc'
end

task default: :spec
