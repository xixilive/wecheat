module Wechat::Controllers
  module Events
    def self.included base
      base.class_eval do

        before '/events/:event/:appid/:openid' do
          @app ||= Wechat::Models::App.find(params[:appid])
          halt(json errcode: 40012, errmsg: "invalid appid") if @app.nil?
          @user ||= @app.user(params[:openid])
          halt(json errcode: 46004) if @user.nil?
        end

        post '/events/:type/:appid/:openid' do
          xml = Wechat::MessageBuilder.new.tap do |builder|
            builder.CreateTime = Time.now.to_i
            builder.cdata 'ToUserName', @user.openid
            builder.cdata 'FromUserName', @app.label
            builder.cdata 'MsgType', 'event'
            builder.cdata 'Event', params[:type]

            case params[:type]
            when 'subscribe'
              unless params[:event_key].nil?
                builder.cdata 'EventKey', params[:event_key] 
                builder.cdata 'Ticket', @app.id
              end

            when 'LOCATION','location'
              builder.cdata 'Latitude', @user.latitude
              builder.cdata 'Longitude', @user.longitude
              builder.cdata 'Precision', @user.precision

            when 'CLICK', 'click'
              builder.cdata 'EventKey', params[:event_key]
            end
          end.to_hash

          begin
            json error: false, response: RestClient.post(app.base_url, xml: xml).to_s
          rescue => e
            json error: e
          end
        end

      end
    end
  end
end