module Wechat
  module FormHelpers
    def message_type_options
      {
        text: '文本消息',
        image: '图片消息',
        voice: '语音消息',
        video: '视频消息',
        music: '音乐消息',
        news: '图文消息'
      }
    end

    def appid_options
      Wechat::Models::App.all.collect{|app| "<option value=\"#{app.id}\">#{app.id}</option>" }.join
    end

    def users_options appid
      app = Wechat::Models::App.find(appid)
      app.users.collect{|user| "<option value=\"#{user.openid}\">#{user.nickname}</option>" }.join if app
    end

    def medias_options appid, type
      ""
    end

    def news_options appid
    end
  end

  module UrlHelpers
    def media_url media
      request.host
    end

    def article_url article
    end

    def article_pic_url article
    end
  end

  class MessageBuilder < Hashie::Mash
    def to_xml
      nodes = []

      self.each_pair do |k,v|
        nodes << "<#{k}>#{v}</#{k}>" unless k.to_s == 'cdatas'
      end

      self.cdatas.each_pair do |k,v|
        nodes << "<#{k}><![CDATA[#{v}]]></#{k}>"
      end
      "<xml>#{nodes.join}</xml>"
    end

    def cdata name, value
      self.cdatas ||= Hashie::Mash.new
      self.cdatas[name] = value
    end

    def to_hash
      h = super
      cdatas = h.delete('cdatas') || {}
      h.merge(cdatas)
    end

  end
end