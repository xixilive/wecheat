module Wecheat::Controllers
  module Apps

    def self.included base
      base.class_eval do

        before '/apps/:id*' do
          @app ||= Wecheat::Models::App.find(params[:id])
          halt(json errcode: 40012, errmsg: "invalid appid") if @app.nil?
        end

        get '/apps/:id' do
          erb :app, locals: { app: @app }
        end

        delete '/apps/:id' do
          @app.delete
          redirect to('/')
        end

        post '/apps/:id/test' do
          begin
            echostr = Wecheat::Utils.rand_secret
            echo = RestClient.get(app.base_url(echostr: echostr)).to_s.strip
            json error: (echostr != echo), response: echo
          rescue => e
            json error: true, response: e.inspect
          end
        end

        #update app
        put '/apps/:id' do
          unless params[:app].nil?
            [:token, :url, :label].each do |attr|
              @app[attr] = params[:app][attr] unless params[:app][attr].nil?
            end
            @app.save
          end
          redirect to("/apps/#{@app.id}"), 302
        end

        get '/apps/:id/message' do
          erb :message, locals: { app: @app }
        end

        post '/apps/:id/message' do
          message = params[:message]
          user, type = @app.user(message[:user]), message[:type]
          halt 404 if user.nil?

          builder = Wecheat::MessageBuilder.new.tap do |b|
            b.cdata 'ToUserName', @app.label
            b.cdata 'FromUserName', message[:user]
            b.cdata 'MsgType', type
            b.CreateTime Time.now.to_i
            b.MsgId Time.now.to_i

            case type
            when 'text' then b.cdata 'Content', message[:content]
            when 'link'
              b.cdata 'Url', message[:url]
              b.cdata 'Title', message[:title]
              b.cdata 'Description', message[:description]

            when 'location'
              b.cdata 'Location_X', user.longitude
              b.cdata 'Location_Y', user.latitude
              b.cdata 'Scale', message[:scale]
              b.cdata 'Label', message[:label]

            when 'image', 'video', 'voice'
              media = @app.media(message[:media_id]) || {}
              b.cdata 'MediaId', media[:id].to_s
              # image message
              b.cdata 'PicUrl', uri(media[:path].to_s) if type == 'image'

              #video message
              b.cdata 'ThumbMediaId', (@app.medias_by_type(:thumb).first || {})[:id] if type == 'video'
              
              #voice message
              b.cdata 'Format', 'mp3' if type == 'voice'

              #recognition of voice if present
              b.cdata 'Recognition', params[:recognition] if type == 'voice' && params[:recognition].to_s.strip != ''
            
            end

          end

          begin
            json error: false, response: RestClient.post(@app.base_url, builder.to_xml).to_s
          rescue => e
            json error: e
          end
          
        end

      end
    end
  end
end