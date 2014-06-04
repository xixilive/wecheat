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
        Dir[File.join(Models.store_dir, "**/*.yml")].each{|f| FileUtils.rm_rf(f) }
      end

      def setup
        app = App.new.tap do |app|
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

        QRCode.new(appid: app.id, action_name: 'QR_SCENE', scene_id: 2014).save
      end
    end

    module Concerns
      module Persistable

        def self.included base
          base.extend ClassMethods
        end

        def write
          FileUtils.mkdir_p(self.class.store_dir) unless Dir.exist?(self.class.store_dir)
          File.open(file_path, 'w'){|f| f.puts self.to_yaml }
          self
        end
        alias :save :write

        def delete
          FileUtils.rm_rf(file_path)
        end
        alias :remove :delete

        def filename;raise NotImplementedError.new; end

        private
        def file_path
          File.join(self.class.store_dir, "#{filename}.yml")
        end

        module ClassMethods
          def find id
            file = File.join(self.store_dir, "#{id}.yml")
            self.new(YAML.load_file(file)) if File.exist?(file)
          end

          def count
            files_collection.size
          end

          def all
            files_collection.collect{|f| self.new(YAML.load_file(f)) }.compact
          end

          def store_dir; raise NotImplementedError.new; end

          private
          def files_collection
            Dir[File.join(self.store_dir, "*.yml")]
          end
        end

      end
    end

    Dir[File.expand_path('./models/*.rb')].each{|f| require f }
  end
end