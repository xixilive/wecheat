module Wecheat::Controllers
  module Apis
    def self.read_body io, parse_json = true
      io.set_encoding('utf-8')
      parse_json ? (JSON.parse(io.string) rescue nil) : io.string
    end

    def self.included base
      base.class_eval do

        before /^\/(message|user|menu|media)\/*/ do
          @app ||= Wecheat::Models::App.find_by_access_token(params[:access_token])
          halt(json errcode: 40001) if @app.nil?
        end

        # to receive message from out-site app
        post '/message/custom/send' do
          session[:received_messages] ||= []
          session[:received_messages].shift if session[:received_messages].size > 9
          session[:received_messages].push({app: @app.label, response: request.POST})
          json errcode: 0
        end

        get '/token' do
          if app = Wecheat::Models::App.find(params[:appid])
            json access_token: app.access_token, expires_in:7200
          else
            json errcode: 40012
          end
        end

        get '/user/get' do
          json total: @app.users.size, count: @app.users.size, data: {openid: @app.users.collect{|u| u.openid }}, next_openid: ''
        end

        get '/user/info' do
          json @app.user(params[:openid]) || {errcode: 46004}
        end

        post '/menu/create' do
          if data = Apis.read_body(request.body)
            @app.button = Wecheat::Models::Button.new(data)
            @app.save
            json errcode: 0
          else
            json errcode: 40015, errmsg: 'invalid button data'
          end
        end

        get '/menu/get' do
          json button: @app.button
        end

        get '/menu/delete' do
          @app.button = []
          @app.save
          json errcode: 0
        end

        get '/media/get' do
          media = @app.media(params[:media_id])
          p File.join(settings.root, media.path)
          unless media.nil?
            send_file File.join(settings.public_folder, media.path)
          else
            json errcode: 40007
          end
        end

        post '/media/upload' do
          type = params[:type].to_s.downcase
          halt(json errcode: 40004) unless ['image', 'thumb', 'video', 'voice'].include?(type)
          media = @app.medias.select{|m| m.type == type}.first
          json type: type, media_id: media.id, created_at: Time.now.to_i
        end

      end
    end
  end
end