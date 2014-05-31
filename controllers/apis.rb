module Wecheat::Controllers
  module Apis
    def self.read_body io, parse_json = true
      io.set_encoding('utf-8')
      parse_json ? (JSON.parse(io.string) rescue nil) : io.string
    end

    def self.included base
      base.class_eval do

        before /^\/api\/(message|user|menu|media)/ do
          @app ||= Wecheat::Models::App.find_by_access_token(params[:access_token])
          halt(json errcode: 40012) if @app.nil?
        end

        # to receive message from out-site app
        post '/api/message/custom/send' do
          Wecheat.log_received_message({app: @app.label, response: Apis.read_body(request.body, false)}.to_json)
          json errcode: 0
        end

        get '/api/token' do
          if app = Wecheat::Models::App.find(params[:appid])
            json access_token: app.access_token, expires_in:7200
          else
            json errcode: 40012
          end
        end

        get '/api/user/get' do
          json total: @app.users.size, count: @app.users.size, data: {openid: @app.users.collect{|u| u.openid }}, next_openid: ''
        end

        get '/api/user/info' do
          json @app.user(params[:openid]) || {errcode: 46004}
        end

        post '/api/menu/create' do
          if data = Apis.read_body(request.body)
            @app.button = Wecheat::Models::Button.new(data)
            @app.save
            json errcode: 0
          else
            json errcode: 40015, errmsg: 'invalid button data'
          end
        end

        get '/api/menu/get' do
          json button: @app.button
        end

        get '/api/menu/delete' do
          @app.button = []
          @app.save
          json errcode: 0
        end

        get '/api/media/get' do
          media = @app.media(params[:media_id])
          p File.join(settings.root, media.path)
          unless media.nil?
            send_file File.join(settings.public_folder, media.path)
          else
            json errcode: 40007
          end
        end

        post '/api/media/upload' do
          type = params[:type].to_s.downcase
          halt(json errcode: 40004) unless ['image', 'thumb', 'video', 'voice'].include?(type)
          media = @app.medias.select{|m| m.type == type}.first
          json type: type, media_id: media.id, created_at: Time.now.to_i
        end

      end
    end
  end
end