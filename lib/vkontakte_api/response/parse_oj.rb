module VkontakteApi
  class ParseOj < Faraday::Response::Middleware
    dependency 'oj'

    def parse(body)
      Oj.load(body, mode: :compat) unless body.strip.empty?
    end
  end
end
