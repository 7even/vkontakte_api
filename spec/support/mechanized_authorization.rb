require 'mechanize'

module MechanizedAuthorization
  class << self
    def client(scope: [:friends, :groups])
      @client ||= begin
        agent = Mechanize.new
        
        configure
        agent.get VkontakteApi.authorization_url(scope: scope, type: :client)
        
        agent.page.form_with(action: /login.vk.com/) do |form|
          form.email = settings.email
          form.pass  = settings.password
        end.submit
        
        # extra form in some cases
        agent.page.form.submit if agent.page.uri.fragment.nil?
        
        # uri.fragment: access_token=ee6b952fa432c70&expires_in=86400&user_id=123456
        token = agent.page.uri.fragment.split('&').each_with_object(Hash.new) do |pair, hash|
          key, value = pair.split('=')
          hash[key] = value
        end.fetch('access_token')
        
        VkontakteApi::Client.new(token)
      end
    end
    
    def on?
      !off?
    end
    
  private
    def off?
      ENV['NO_AUTH'] || !File.exists?(credentials_path)
    end
    
    def configure
      VkontakteApi.configure do |config|
        config.app_id     = settings.app_id
        config.app_secret = settings.app_secret
      end
    end
    
    def settings
      @settings ||= Hashie::Mash.new(settings_hash)
    end
    
    def settings_hash
      YAML.load_file(credentials_path)
    end
    
    def credentials_path
      File.expand_path('../credentials.yml', __FILE__)
    end
  end
end
