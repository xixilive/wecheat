module Wecheat::Models

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

end