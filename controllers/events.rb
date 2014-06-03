class WecheatApp

  before '/events/:event/:appid/:openid' do
    @app ||= Wecheat::Models::App.find(params[:appid])
    halt(json errcode: 40012, errmsg: "invalid appid") if @app.nil?
    @user ||= @app.user(params[:openid])
    halt(json errcode: 46004) if @user.nil?
  end

  post '/events/:type/:appid/:openid' do
    builder = Wecheat::MessageBuilder.new.tap do |b|
      b.CreateTime = Time.now.to_i
      b.cdata 'ToUserName', @app.label
      b.cdata 'FromUserName', @user.openid
      b.cdata 'MsgType', 'event'
      b.cdata 'Event', params[:type]

      case params[:type].to_s.downcase
      when 'location'
        b.cdata 'Latitude', @user.latitude
        b.cdata 'Longitude', @user.longitude
        b.cdata 'Precision', @user.precision

      when 'click', 'view'
        b.cdata 'EventKey', params[:event_key]
      end
    end

    begin
      res = RestClient.post(@app.base_url, data, content_type: 'text/xml; charset=utf-8')
      res.force_encoding('utf-8') unless res.encoding.name == 'UTF-8'
      json error: false, response: res
    rescue => e
      json error: true, response: e.inspect
    end
  end

end