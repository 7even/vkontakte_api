class VkontakteApi::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_initializer
    copy_file 'initializer.rb', 'config/initializers/vkontakte_api.rb'
  end
end
