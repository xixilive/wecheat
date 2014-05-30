module Wechat::Controllers
  module Apps

    def self.included base
      base.class_eval do

        before '/apps/:id*' do
          @app ||= Wechat::Models::App.find(params[:id])
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
            echostr = Wechat::Utils.rand_secret
            json echo: RestClient.get(app.base_url(echostr: echostr)).to_s == echostr
          rescue => e
            json echo: e
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

      end
    end
  end
end