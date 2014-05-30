module Wechat::Controllers
  module Messages
    def self.included base
      base.class_eval do
        
        get '/messages' do
          json session[:received_messages]
        end

        get '/apps/:id/message' do
          erb :message, locals: { app: Wechat::Models::App.find(params[:id]) }
        end

        post '/apps/:id/message' do
          app = Wechat::Models::App.find(params[:id])
          RestClient.post(app.url, params[:message])
        end

      end
    end
  end
end