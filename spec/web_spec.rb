ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'web'

RSpec.describe Scheduling::Web do
  include Rack::Test::Methods

  def app
    Scheduling::Web.freeze.app
  end

  describe 'GET /' do
    before { get '/' }

    it 'it has 200 status' do
      expect(last_response).to be_ok
    end

    it 'has form' do
      expect(last_response.body).to match %r{form}i
    end
  end

  describe 'POST analyze' do
    let(:slug) { 'my_slug' }
    let(:computing_slug) { 'computing_my_slug' }
    let(:redis) { double('Redis', get: true, set: true) }
    let(:worker) { double('ProblemWorker', perform_async: true) }
    let(:slugger) { double('Slugger', generate_slug: slug, computing_slug: computing_slug) }
    let(:params) do
      {
        "building_count"=>"8",
        "machine_count"=>"3",
        "type"=>"smarter",
        "iterations_count"=>"100",
        "tabu_size"=>"30",
        "tabu_type"=>"random",
        "input"=>"1, 1, 3, 6, 9\r\n1, 2, 2, 6, 9\r\n1, 3, 2, 7, 11\r\n2, 1, 2, 6, 8\r\n2, 2, 1, 6, 9\r\n2, 3, 3, 7, 9\r\n3, 1, 1, 5, 8\r\n3, 2, 1, 4, 8\r\n3, 3, 3, 7, 10\r\n4, 1, 1, 5, 9\r\n4, 2, 1, 5, 8\r\n4, 3, 3, 7, 11\r\n5, 1, 1, 6, 9\r\n5, 2, 2, 6, 10\r\n5, 3, 2, 7, 11\r\n6, 1, 2, 6, 8\r\n6, 2, 3, 8, 12\r\n6, 3, 2, 6, 8\r\n7, 1, 2, 6, 8\r\n7, 2, 3, 8, 10\r\n7, 3, 2, 5, 7\r\n8, 1, 2, 5, 9\r\n8, 2, 3, 6, 8\r\n8, 3, 3, 7, 11\r\n            ",
        "submit"=>""
      }
    end

    before do
      stub_const('Scheduling::REDIS', redis)
      stub_const('Scheduling::ProblemWorker', worker)
      stub_const('Scheduling::Slugger', slugger)
      post '/analyze', params
    end

    it 'performs job' do
      expect(worker).to have_received(:perform_async).with(params, slug)
    end

    it 'sets redis key' do
      expect(slugger).to have_received(:generate_slug)
      expect(slugger).to have_received(:computing_slug).with(slug)
      expect(redis).to have_received(:set).with(computing_slug, true)
    end

    it 'redirects to report view' do
      expect(last_response).to be_redirect
      expect(last_response.location).to eq '/view_report/my_slug'
    end
  end

  describe 'GET /view_report' do
    let(:slug) { 'my_slug' }
    let(:computing_slug) { 'computing_my_slug' }
    let(:slugger) { double('Slugger', generate_slug: slug, computing_slug: computing_slug) }

    before do
      stub_const('Scheduling::Slugger', slugger)
    end

    context 'reports exists' do
      let(:redis) { double('Redis', get: true, set: true) }

      before do
        stub_const('Scheduling::REDIS', redis)
        get "/view_report/#{slug}"
      end

      it 'renders report view' do
        expect(slugger).to have_received(:computing_slug).with slug
        expect(redis).to have_received(:get).with computing_slug
        expect(last_response).to be_ok
        expect(last_response.body).to match %r{report}i
      end
    end

    context 'report does not exist' do
      let(:redis) { double('Redis', get: false, set: true) }

      before do
        stub_const('Scheduling::REDIS', redis)
        get "/view_report/#{slug}"
      end

      it 'redirects to root' do
        expect(last_response).to be_redirect
        expect(last_response.location).to eq '/'
      end
    end
  end

  describe 'GET /view_report' do
    let(:slug) { 'my_slug' }
    let(:json_string) { '{ value: "s" }' }
    let(:redis) { double('Redis', get: json_string, set: true) }

    before do
      stub_const('Scheduling::REDIS', redis)
      get "/get_report/#{slug}"
    end
    context 'report exists' do
      it 'renders value' do
        expect(last_response).to be_ok
        expect(last_response.headers['Content-Type']).to eq 'text/json'
      end
    end

    context 'report does not exist' do
      let(:redis) { double('Redis', get: false, set: true) }

      before do
        stub_const('Scheduling::REDIS', redis)
        get "/get_report/#{slug}"
      end

      it 'sets status to 403' do
        expect(last_response.status).to eq 403
      end
    end
  end

  describe 'Not found' do
    before { get '/asdasdasfdfsncncn11' }

    it 'redirects to root' do
      expect(last_response).to be_redirect
      expect(last_response.location).to eq '/'
    end
  end
end
