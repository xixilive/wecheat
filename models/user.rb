module Wecheat::Models

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
    property :headimgurl, default: 'https://avatars1.githubusercontent.com/u/715278?u=fc3166596a089d54223b3fdcd5d0a530854d8ebf&s=140'
    property :subscribe_time, required: true
    property :latitude, required: true
    property :longitude, required: true
    property :precision, required: true

    def initialize(attributes = {}, &block)
      attributes[:openid] ||= Wecheat::Utils.rand_openid
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

end