require 'open-uri'
module Wecheat::Models
  class QRCode < Hashie::Dash
    include Hashie::Extensions::IgnoreUndeclared
    include Concerns::Persistable

    property :appid
    property :ticket, required: true
    property :action_name
    property :expire_seconds, default: 0
    property :scene_id
    property :created,  default: Time.now.to_i

    def self.store_dir
      File.join(Wecheat::Models.store_dir, 'qrcodes')
    end

    def initialize(attributes = {}, &block)
      attributes[:ticket] ||= Time.now.strftime('%s%L')
      super(attributes, &block)
    end

    def expired?
      action_name == 'QR_SCENE' && created + expire_seconds.to_i > Time.now.to_i
    end

    def action_info
      Hashie::Mash.new(scene: { scene_id: self.scene_id.to_i })
    end

    def app
      Wecheat::Models::App.find(self.appid)
    end

    def image data
      open("http://chart.googleapis.com/chart?cht=qr&chs=200x200&chl=#{data}").read
    end

    protected
    def filename
      self.ticket.to_s
    end

  end
end