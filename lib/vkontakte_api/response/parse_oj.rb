module VkontakteApi
  # Faraday middleware for parsing JSON response body with
  # [Oj](https://github.com/ohler55/oj).
  class ParseOj < Faraday::Response::Middleware
    dependency 'oj'
    
    # Keeps raw response body and makes a new `response.body` with `#parse`.
    def on_complete(env)
      if respond_to?(:parse) && env.parse_body?
        env[:raw_body] = env.body
        env.body = parse(env.body)
      end
    end
    
    # Parses the response body woth `Oj`.
    # @param [String] body The response body.
    # @return [Hash, Array] Parsed body.
    def parse(body)
      Oj.load(body, mode: :compat) unless body.strip.empty?
    end
  end
  
  Faraday::Response.register_middleware oj: ParseOj
end
