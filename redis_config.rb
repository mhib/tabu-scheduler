module Scheduling
  REDIS = Redis.new(url: ENV.fetch('REDIS_ADDR') { 'redis://localhost' })
end
