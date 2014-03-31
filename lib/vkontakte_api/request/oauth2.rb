require 'faraday'
require 'forwardable'

module VkontakteApi
  # Public: A simple middleware that adds an access token to each request.
  #
  # The token is added as both "access_token" query parameter and the
  # "Authorization" HTTP request header. However, an explicit "access_token"
  # parameter or "Authorization" header for the current request are not
  # overriden.
  #
  # @example
  #   # configure default token:
  #   OAuth2Middleware.new(app, 'abc123')
  #
  #   # configure query parameter name:
  #   OAuth2Middleware.new(app, 'abc123', param_name: 'my_oauth_token')
  #
  #   # default token value is optional:
  #   OAuth2Middleware.new(app, param_name: 'my_oauth_token')
  class OAuth2Middleware < Faraday::Middleware
    # Default access token parameter name.
    PARAM_NAME  = 'access_token'.freeze
    # Default access token header name.
    AUTH_HEADER = 'Authorization'.freeze
    
    attr_reader :param_name
    
    extend Forwardable
    def_delegators :'Faraday::Utils', :parse_query, :build_query
    
    # Adds access_token to request params.
    def call(env)
      params = { param_name => @token }.update query_params(env[:url])
      
      if token = params[param_name] and !token.empty?
        env[:url].query = build_query(params)
        env[:request_headers][AUTH_HEADER] ||= %(Token token="#{token}")
      end
      
      @app.call(env)
    end
    
    # Initializes the middleware.
    def initialize(app, token = nil, options = {})
      super(app)
      options, token = token, nil if token.is_a?(Hash)
      @token = token && token.to_s
      @param_name = options.fetch(:param_name, PARAM_NAME).to_s
      raise ArgumentError, ":param_name can't be blank" if @param_name.empty?
    end
    
    # Extracts query params from the URL.
    def query_params(url)
      if url.query.nil? or url.query.empty?
        {}
      else
        parse_query(url.query)
      end
    end
  end
  
  Faraday::Request.register_middleware oauth2: OAuth2Middleware
end
