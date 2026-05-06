# frozen_string_literal: true

module Uniword
  module Builder
    # Base class for builders that wrap a single model object.
    #
    # Provides the shared initialize/from_model/build pattern used by
    # most builders in the module. Subclasses must implement
    # .default_model_class to specify the model type to create when
    # none is provided.
    #
    # @example Subclass with defaults
    #   class MyBuilder < BaseBuilder
    #     def self.default_model_class
    #       Wordprocessingml::MyModel
    #     end
    #   end
    #
    #   builder = MyBuilder.new           # creates new MyModel
    #   builder = MyBuilder.new(existing) # wraps existing model
    #   builder = MyBuilder.from_model(m) # same as new(m)
    #   model = builder.build             # returns @model
    class BaseBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || self.class.default_model_class.new
      end

      def self.from_model(model)
        new(model)
      end

      def build
        @model
      end

      def self.default_model_class
        raise NotImplementedError,
              "#{name} must implement .default_model_class"
      end
    end
  end
end
