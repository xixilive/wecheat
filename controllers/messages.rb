module Wecheat::Controllers
  module Messages
    def self.included base
      base.class_eval do
        
        get '/messages' do
          json session[:received_messages]
        end

      end
    end
  end
end