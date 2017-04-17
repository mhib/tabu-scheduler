require 'sidekiq'
require_relative '../lib/scheduling'

class DeleteProblemWorker
  include Sidekiq::Worker

  def perform(slug)
    Scheduling::REDIS.del(slug)
    Scheduling::REDIS.del(Scheduling::Slugger.computing_slug(slug))
  end
end
