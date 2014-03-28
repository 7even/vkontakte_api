module VkontakteApi
  class ParseOj < Faraday::Response::Middleware
    dependency 'oj'

    def on_complete(env)
      if respond_to?(:parse) && env.parse_body?
        env[:raw_body] = env.body
        env.body = parse(env.body)
      end
    end

    def parse(body)
      Oj.load(body, mode: :compat) unless body.strip.empty?
    end
  end

  Faraday::Response.register_middleware oj: ParseOj
end
