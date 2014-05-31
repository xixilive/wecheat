require 'faker'
require 'uri'
require 'hashie'
require './utils'

module Wecheat
  module Models
    class << self
      def store_dir
        File.expand_path('../db', __FILE__)
      end

      def purge
        Dir[File.join(Models.store_dir, "*.yml")].each{|f| FileUtils.rm_rf(f) }
      end

      def setup
        App.new.tap do |app|
          (rand(3)+1).times do
            app.users << User.new
          end

          (rand(3)+1).times do
            app.medias << Media.new(type: 'image', path: '/medias/sample.jpg')
            app.medias << Media.new(type: 'thumb', path: '/medias/sample.jpg')
            app.medias << Media.new(type: 'video', path: '/medias/sample.mp4')
            app.medias << Media.new(type: 'voice', path: '/medias/sample.mp3')
          end
        end.save
      end
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
        attr_reader :filename, :store_dir

        def write
          File.open(store_dir, 'w'){|f| f.puts self.to_yaml }
        end
        alias :save :write

        def delete
          FileUtils.rm_rf(store_dir)
        end
        alias :remove :delete

        def store_dir
          File.join(Models.store_dir, "#{filename}.yml")
        end

      end
    end

    Dir[File.expand_path('./models/*.rb')].each{|f| require f }
  end
end