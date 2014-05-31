module Wecheat
  module Models
    
    class Button < Hashie::Dash
      property :button, default: []

      def items
        self.button.collect do |btn|
          item = Item.new(btn)
        end
      end

      class Item < Hashie::Dash
        include Hashie::Extensions::IgnoreUndeclared
        property :name, required: true
        property :type
        property :key
        property :url
        property :sub_button, default: []

        def sub_items?
          self.sub_button.size > 0
        end

        def items
          self.sub_button.collect do |btn|
            item = Item.new(btn)
          end
        end
      end
    end

  end
end