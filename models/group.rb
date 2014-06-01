module Wecheat::Models
  class Group < Hashie::Dash
    include Hashie::Extensions::IgnoreUndeclared
    property :id, required: true
    property :name, required: true, default: 'unamed'

    def initialize(attributes = {}, &block)
      attributes[:id] ||= Time.now.strftime('%s%L')
      super(attributes, &block)
    end

  end
end