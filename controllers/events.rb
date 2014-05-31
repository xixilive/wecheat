module Wecheat::Controllers
  module Events
    def self.included base
      base.class_eval do

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
            when 'subscribe'
              unless params[:event_key].nil?
                b.cdata 'EventKey', params[:event_key] 
                b.cdata 'Ticket', @app.id
              end

            when 'location'
              b.cdata 'Latitude', @user.latitude
              b.cdata 'Longitude', @user.longitude
              b.cdata 'Precision', @user.precision

            when 'click', 'view'
              b.cdata 'EventKey', params[:event_key]
            end
          end

          begin
            json error: false, response: RestClient.post(app.base_url, builder.to_xml).to_s
          rescue => e
            json error: true, response: e.inspect
          end
        end

      end
    end
  end
end