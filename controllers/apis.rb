module Wechat::Controllers
  module Apis

    def self.included base
      base.class_eval do

        before /^\/(message|user|menu|media)\/*/ do
          @app = Wechat::Models::App.find_by_access_token(params[:access_token])
          halt(json errcode: 40001) if @app.nil?
        end

        # to receive message from out-site app
        post '/message/custom/send' do
          session[:received_messages] ||= []
          session[:received_messages].shift if session[:received_messages].size > 9
          session[:received_messages].push request.POST
          json errcode: 0, errmsg: "ok"
        end

        get '/token' do
          if app = Wechat::Models::App.find(params[:appid])
            json access_token: app.access_token, expires_in:7200
          else
            json errcode: 40012, errmsg: "invalid appid"
          end
        end

        get '/user/get' do
          json total: @app.users.size, count: @app.users.size, data: {openid: @app.users.collect{|u| u.openid }}, next_openid: ''
        end

        get '/user/info' do
          json @app.user(params[:openid]) || {errcode: 46004}
        end

        post '/menu/create' do
          @app.button = Wechat::Models::Button.new(request.POST)
          @app.save
          json errcode: 0, errmsg: "ok"
        end

        get '/menu/get' do
          json button: @app.button
        end

        get '/menu/delete' do
          @app.button = []
          @app.save
          json errcode: 0, errmsg: "ok"
        end

        get '/media/get' do
          media = @app.media(params[:media_id])
          unless media.nil?
            send_file File.join(root, media.path)
          else
            json errcode: 40007, errmsg: "invalid media"
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