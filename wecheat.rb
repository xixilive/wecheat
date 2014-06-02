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

  get '/scan/:ticket/:openid/:type' do
    qrcode = Wecheat::Models::QRCode.find(params[:ticket])

    builder = Wecheat::MessageBuilder.new.tap do |b|
      b.CreateTime = Time.now.to_i
      b.cdata 'ToUserName', app.label
      b.cdata 'FromUserName', params[:openid]
      b.cdata 'MsgType', 'event'
      b.cdata 'Event', 'subscribe'
      b.cdata 'EventKey', params[:type] == 0 ? "qrscene_#{qrcode.scene_id}" : qrcode.scene_id
      b.cdata 'Ticket', qrcode.ticket
    end

    begin
      RestClient.post(app.base_url, builder.to_xml).to_s
    rescue => e
      e.inspect
    end

  end

end

Dir[File.expand_path('./controllers/*.rb')].each{|f| require f }