module Wecheat::Models

  class Media < Hashie::Dash
    include Hashie::Extensions::IgnoreUndeclared
    property :id, required: true
    property :type, required: true, default: ''
    property :path
    property :title
    property :description
    property :articles, default: []

    def initialize(attributes = {}, &block)
      attributes[:id] ||= Time.now.strftime('%s%L')
      super(attributes, &block)
    end
  end

  class Article < Hashie::Dash
    include Hashie::Extensions::IgnoreUndeclared

    property :thumb_media_id
    property :author
    property :title
    property :content
    property :content_source_url
    property :digest
    property :show_cover_pic

  end

end