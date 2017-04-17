require 'sidekiq'
require_relative '../lib/scheduling'
require 'scheduling/problem_easier'
require 'scheduling/problem_smarter'
require 'scheduling/redis_config'
require 'scheduling/slugger'

class DeleteProblemWorker
  include Sidekiq::Worker

  def perform(slug)
    Scheduling::REDIS.del(slug)
    Scheduling::REDIS.del(Scheduling::Slugger.computing_slug(slug))
  end
end
