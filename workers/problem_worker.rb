require 'sidekiq'
require_relative 'delete_problem_worker'
require_relative '../lib/scheduling'
require 'scheduling/problem_easier'
require 'scheduling/problem_smarter'
require 'scheduling/problem_all_permutations'
require 'scheduling/redis_config'

class ProblemWorker
  include Sidekiq::Worker

  PROBLEMS_MAP = {
    'easier'.freeze => Scheduling::ProblemEasier,
    'smarter'.freeze => Scheduling::ProblemSmarter,
    'all_permutations'.freeze => Scheduling::ProblemAllPermutations
  }
  DELETE_DELAY = 5 * 60

  def perform(params, slug)
    start = Time.now.to_f
    klass = PROBLEMS_MAP[params['type']]
    res = klass.new(*problem_arguments(params)).call
    Scheduling::REDIS.set(slug, {
      table: res.first,
      min: res.last.min,
      mid: res.last.mid,
      max: res.last.max,
      duration: duration(start)
    }.to_json)
    DeleteProblemWorker.perform_in(DELETE_DELAY, slug)
  rescue
    Scheduling::REDIS.set(slug, {
      error: "true"
    }.to_json)
  end

  private

  def blank?(str)
    str.empty? || /\A[[:space:]]*\z/ === str
  end

  def problem_arguments(params)
    [
      params['input'].split("\n").map do |n|
        Scheduling::TimePrediction.new(*n.split(',').map(&:to_f)) unless blank?(n)
      end.compact,
      params['building_count'].to_i,
      params['machine_count'].to_i,
      [2000, params['iterations_count'].to_i].min,
      [100, params['tabu_size'].to_i].min,
      params['tabu_type']
    ]
  end

  def duration(start)
    Time.at((Time.now.to_f - start)).utc.strftime "%H:%M:%S.%L"
  end
end
