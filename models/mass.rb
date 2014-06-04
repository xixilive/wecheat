module Wecheat::Models
  class Mass < Hashie::Dash
    include Hashie::Extensions::IgnoreUndeclared
    include Concerns::Persistable

    property :id, required: true
    property :appid
    property :response, default: ''
    property :request, default: ''

    def initialize attributes={}, &block
      attributes[:id] ||= Time.now.strftime '%s%L'
      super(attributes, &block)
    end

    def self.store_dir
      File.join(Wecheat::Models.store_dir, 'mass')
    end

    def self.first
      f = Dir[File.join(self.store_dir, "*.yml")].sort.first
      self.new(YAML.load_file(f)) unless f.nil?
    end

    def filename
      self.id.to_s
    end

    def app
      Wecheat::Models::App.find(self.appid)
    end

  end
end