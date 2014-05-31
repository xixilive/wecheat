require 'sinatra'
require 'sinatra/json'
require 'rest_client'
require 'erb'

require './models'
require './helpers'
require './controllers'

class WecheatApp < Sinatra::Base

  configure do
    set :method_override, true
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

  include Wecheat::Controllers
end
