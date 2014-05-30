require 'sinatra'
require 'sinatra/json'
require 'rest_client'
require 'erb'
require 'hashie'

require './models'
require './helpers'
require './controllers'

class WechatFaker < Sinatra::Base

  configure do
    set :method_override, true
  end

  use Rack::Session::Pool, expire_after: 300
  helpers Wechat::FormHelpers

  get "/favicon.ico" do
  end

  get '/' do
    erb :index, locals: { apps: Wechat::Models::App.all }
  end

  include Wechat::Controllers
end
