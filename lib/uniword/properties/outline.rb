# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Outline text effect element
    #
    # Represents <w:outline/> or <w:outline w:val="false"/>
    # Used in run properties (w:rPr) for outline text effect
    class Outline < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'outline'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end

      # Handle boolean-like values for val attribute
      # nil = true (element present without val means true)
      # 'false' = false
      def initialize(attrs = {})
        if [true, 'true'].include?(attrs[:val])
          attrs[:val] = nil # true = no val attribute
        elsif [false, 'false'].include?(attrs[:val])
          attrs[:val] = 'false'
        end
        super
      end
    end
  end
end
