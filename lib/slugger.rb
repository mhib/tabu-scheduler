require 'securerandom'
require_relative 'redis_config'

module Scheduling
  module Slugger
    module_function

    def computing_slug(slug)
      "computing_#{slug}"
    end

    def generate_slug
      slug = nil
      loop do
        slug = "problem_#{SecureRandom.urlsafe_base64(30)}";
        break unless REDIS.get(slug) || REDIS.get(computing_slug(slug))
      end
      slug
    end
  end
end
