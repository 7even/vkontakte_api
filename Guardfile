guard 'rspec', all_on_start: true, all_after_pass: true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
  
  watch('spec/support/mechanized_authorization.rb') { 'spec/integration_spec.rb' }
end

guard 'yard' do
  watch(%r{lib/.+\.rb})
end

notification :terminal_notifier, activate: 'com.googlecode.iTerm2'
