# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # Base class for all OOXML element classes.
  #
  # In v2.0 architecture, all elements inherit from Lutaml::Model::Serializable
  # for XML serialization. This base class provides common functionality and
  # serves as a common ancestor for all Uniword elements.
  #
  # @example Creating a custom element
  #   class MyElement < Uniword::Element
  #     attribute :name, :string
  #
  #     xml do
  #       element 'myElement'
  #       namespace 'http://example.com/ns'
  #       map_attribute 'name', to: :name
  #     end
  #   end
  class Element < Lutaml::Model::Serializable
    # Common ID attribute for all elements
    attribute :id, :string

    # Allow elements to track if they're abstract (for visitor pattern)
    class << self
      def abstract?
        @abstract || false
      end

      def abstract!
        @abstract = true
      end
    end

    # Accept method for visitor pattern
    # Subclasses should override this method
    def accept(visitor)
      visitor.visit_element(self)
    end
  end
end
