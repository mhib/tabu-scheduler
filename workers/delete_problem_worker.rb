require 'sidekiq'
require_relative '../lib/problem_easier'
require_relative '../lib/problem_smarter'
require_relative '../redis_config'
require_relative '../slugger'
require 'pry'

class DeleteProblemWorker
  include Sidekiq::Worker

  def perform(slug)
    Scheduling::REDIS.del(slug)
    Scheduling::REDIS.del(Scheduling::Slugger.computing_slug(slug))
  end
end
