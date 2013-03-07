require 'mechanize'

module MechanizedAuthorization
  class << self
    def client
      @client ||= begin
        agent = Mechanize.new
        
        configure
        agent.get VkontakteApi.authorization_url(scope: [:friends, :groups])
        
        agent.page.form_with(action: /login.vk.com/) do |form|
          form.email = settings.email
          form.pass  = settings.password
        end.submit
        
        code = agent.page.uri.fragment.sub('code=', '')
        VkontakteApi.authorize(code: code)
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
      @settings ||= Hashie::Mash.new(YAML.load_file credentials_path)
    end
    
    def credentials_path
      File.expand_path('../credentials.yml', __FILE__)
    end
  end
end
