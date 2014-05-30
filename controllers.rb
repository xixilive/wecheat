module Wechat
  module Controllers
    Dir[File.expand_path('./controllers/*.rb')].each{|f| require f }
    
    def self.included base
      Controllers.constants.each do |controller|
        base.send :include, Controllers.const_get(controller)
      end
    end
  end
end