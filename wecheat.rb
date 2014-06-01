require 'sinatra'
require 'sinatra/json'
require 'rest_client'
require 'erb'

require './models'
require './helpers'

class WecheatApp < Sinatra::Base

  configure do
    set :method_override, true
  end

  before do
    request.body.set_encoding('utf-8')
  end

  helpers Wecheat::FormHelpers
  helpers Wecheat::UrlHelpers
  helpers Wecheat::HtmlHelpers

  get "/favicon.ico" do;end

  get '/' do
    erb :index, locals: { apps: Wecheat::Models::App.all }
  end

  post '/' do
    Wecheat::Models.setup
    redirect to('/')
  end

  delete '/' do
    Wecheat::Models.purge
    redirect to('/')
  end

  get '/message' do
    json Wecheat::Utils.read_received_message
  end

end

Dir[File.expand_path('./controllers/*.rb')].each{|f| require f }