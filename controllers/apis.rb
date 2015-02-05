class WecheatApp

  before /^\/api\/(?!(token|showqrcode))/ do
    @app ||= Wecheat::Models::App.find_by_access_token(params[:access_token])
    halt(json errcode: 40014) if @app.nil?
  end

  post '/api/message/custom/send' do
    Wecheat::Utils.log_received_message({app: @app.label, response: request.body.read}.to_json)
    json errcode: 0
  end

  get '/api/token' do
    if app = Wecheat::Models::App.find(params[:appid])
      json access_token: app.access_token, expires_in:7200
    else
      json errcode: 40013
    end
  end

end

Dir[File.expand_path('../apis/*.rb',__FILE__)].each{|f| require f }
