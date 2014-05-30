require 'faker'
require 'uri'
require './utils'

module Wechat
  module Models
    def self.store_dir
      File.expand_path('../db', __FILE__)
    end

    def self.purge
      Dir[File.join(Models.store_dir, "*.yml")].each{|f| FileUtils.rm_rf(f) }
    end

    def self.setup
      App.new.tap do |app|
        (rand(5)+1).times do
          app.users << User.new
        end

        (rand(3)+1).times do
          app.medias << Media.new(type: 'image', path: '/medias/sample.jpg')
          app.medias << Media.new(type: 'thumb', path: '/medias/sample.jpg')
          app.medias << Media.new(type: 'video', path: '/medias/sample.mp4')
          app.medias << Media.new(type: 'voice', path: '/medias/sample.mp3')
        end

        (rand(3)+1).times do
          app.articles << Article.new(pic_path: '/medias/sample.jpg')
        end
      end.save
    end

    module Concerns
      module Findable
        def find id
          file = File.join(Models.store_dir, "#{id}.yml")
          self.new(YAML.load_file(file)) if File.exist?(file)
        end

        def all
          Dir[File.join(Models.store_dir, "*.yml")].collect{|f| self.new(YAML.load_file(f)) }.compact
        end
      end

      module Persistable
        attr_reader :filename

        def write
          File.open(File.join(Models.store_dir, "#{filename}.yml"), 'w'){|f| f.puts self.to_yaml }
        end
        alias :save :write

      end
    end

    class App < Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared
      include Concerns::Persistable
      extend Concerns::Findable

      property :id, required: true
      property :secret, required: true
      property :access_token, required: true
      property :label
      property :token, default: ''
      property :url,  default: ''
      property :users, default: []
      property :medias, default: []
      property :articles, default: []
      property :button, default: []

      def self.find_by_access_token token
        self.all.select{|app| app.access_token == token }.first
      end

      def initialize(attributes = {}, &block)
        attributes[:id] ||= Wechat::Utils.rand_appid
        attributes[:secret] ||= Wechat::Utils::rand_secret
        attributes[:access_token] ||= Wechat::Utils.rand_token
        super(attributes, &block)
      end

      def filename
        self.id
      end

      def base_url append_params = {}
        signed_params = Wechat::Utils.sign_params({
          timestamp: Time.now.to_i,
          nonce: Wechat::Utils.rand_secret
        }.merge(append_params), self.token)
        segments = [self.url, URI.encode_www_form(signed_params)]
        (self.url.to_s.include?('?') ? segments.join("&") : segments.join("?")).gsub(/(\?\&)|(\&\?)/,'?')
      end

      def label
        self[:label] || self.id
      end

      def user id
        find_resource :users, :openid, id
      end

      def media id
        find_resource :medias, :id, id
      end

      def article id
        find_resource :articles, :id, id
      end

      private
      def find_resource name, key, value
        self[name].select{|o| o[key] == value }.first
      end
    end

    class User < Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared
      property :openid, required: true
      property :subscribe, default: '1', required: true
      property :nickname, required: true
      property :sex,  required: true
      property :language, default: 'zh_CN'
      property :city, required: true
      property :province, required: true
      property :country,  required: true
      property :headimgurl, default: ''
      property :subscribe_time, required: true
      property :latitude, required: true
      property :longitude, required: true
      property :precision, required: true

      def initialize(attributes = {}, &block)
        attributes[:openid] ||= Wechat::Utils.rand_openid
        attributes[:nickname] ||= Faker::Internet.user_name
        attributes[:sex] ||= %w(0 1 2)[rand(3)]
        attributes[:city] ||= Faker::Address.city
        attributes[:province] ||= Faker::Address.state
        attributes[:country] ||= Faker::Address.country
        attributes[:subscribe_time] ||= Time.now.to_i - rand(86400*30)
        attributes[:latitude] ||= Faker::Address.latitude
        attributes[:longitude] ||= Faker::Address.longitude
        attributes[:precision] ||= 100

        super(attributes, &block)
      end

    end

    class Media < Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared
      property :id, required: true
      property :type, required: true, default: ''
      property :path, required: true, default: ''

      def initialize(attributes = {}, &block)
        attributes[:id] ||= (Time.now.to_i | rand(100000))
        super(attributes, &block)
      end

    end

    class Article < Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared
      property :id, required: true
      property :title, required: true
      property :description, required: true
      property :pic_path, required: true, default: ''

      def initialize(attributes = {}, &block)
        attributes[:id] ||= (Time.now.to_i | rand(100000))
        attributes[:title] ||= Faker::Lorem.sentence
        attributes[:description] ||= Faker::Lorem.paragraph
        super(attributes, &block)
      end

    end

    class Button < Hashie::Dash
      include Hashie::Extensions::IgnoreUndeclared
      property :type, required: true
      property :name, required: true
      property :key
      property :url
    end

  end

end