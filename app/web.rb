require 'roda'
require_relative '../workers/problem_worker'
require_relative '../lib/scheduling'
require 'scheduling/redis_config'
require 'scheduling/slugger'

module Scheduling
  class Web < Roda
    plugin :render,
      escape: true,
      layout_opts: {template: 'layout', ext: 'erb'},
      template_opts: {default_encoding: 'UTF-8'}
    plugin :content_for
    plugin :not_found

    not_found do |r|
      r.redirect "/"
    end

    route do |r|
      r.root do
        view :index
      end

      r.post 'analyze' do
        slug = Slugger.generate_slug
        REDIS.set(Slugger.computing_slug(slug), true)
        ProblemWorker.perform_async(r.params, slug)
        r.redirect "/view_report/#{slug}"
      end

      r.get 'view_report', :slug do |slug|
        r.redirect '/' unless REDIS.get Slugger.computing_slug(slug)
        @slug = slug
        view :report
      end

      r.get 'get_report', :id do |id|
        if (val = REDIS.get(id))
          response['Content-Type'] = 'text/json'
          val
        else
          response.status = 403
        end
      end
    end
  end
end
