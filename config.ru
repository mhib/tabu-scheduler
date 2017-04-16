require 'roda'
require 'redis'
require_relative 'workers/problem_worker'
require_relative 'workers/delete_problem_worker'
require_relative 'redis_config'
require_relative 'slugger'

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
        r.redirect "/view_raport/#{slug}"
      end

      r.get 'view_raport', :slug do |slug|
        r.redirect '/' unless REDIS.get Slugger.computing_slug(slug)
        @slug = slug
        view :raport
      end

      r.get 'get_raport', :id do |id|
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
run Scheduling::Web.freeze.app
