# A rails generator `vkontakte_api:install`.
# It creates a config file in `config/initializers/vkontakte_api.rb`.
class VkontakteApi::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  # Creates the config file.
  def create_initializer
    copy_file 'initializer.rb', 'config/initializers/vkontakte_api.rb'
  end
end
