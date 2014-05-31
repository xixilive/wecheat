module Wecheat
  module HtmlHelpers
    def app_none_url_alert app, with_link = false, text_only = false
      unless app.url?
        style = text_only ? 'text-danger' : 'alert alert-danger'
        '<p class="%s">Needs to %s for this app!</p>' % [style, (with_link ? "<a href=\"/apps/#{app.id}\">set url</a>" : "set url")]
      end
    end
  end

  module FormHelpers
    def users_select_options collection
      select_options(collection){|item| [item.openid, item.nickname] }
    end

    def medias_select_options collection
      select_options(collection){|item| [item.id, "#{item.path} (ID:#{item.id})"] }
    end

    def select_options collection, &block
      collection.collect do |item|
        options = yield(item)
        "<option value=\"#{options[0]}\">#{options[1]}</option>"
      end.join
    end
  end

  module UrlHelpers
    def media_url media
      uri media.path
    end

    def article_url article
      uri "/articles/#{article.id}"
    end

    def article_pic_url article
      uri article.pic_path
    end

    def menu_item_url item, appid, openid
      evt_key = item.type.to_s.downcase == 'click' ? item.key : CGI.escape(item.url.to_s)
      '/events/%s/%s/%s?event_key=%s' % [item.type, appid, openid, evt_key]
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