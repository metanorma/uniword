# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Table row properties
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:trPr>
    class TableRowProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML
      attribute :height, :integer
      attribute :height_rule, :string
      attribute :header, :boolean
      attribute :cant_split, :boolean

      xml do
        element 'trPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'val', to: :height
        map_attribute 'hRule', to: :height_rule
        map_element 'tblHeader', to: :header, render_nil: false
        map_element 'cantSplit', to: :cant_split, render_nil: false
      end

      # Accept table_header: keyword for docx-js API compatibility
      def initialize(attrs = {})
        # Handle table_header: keyword (alias for header:)
        if attrs.key?(:table_header)
          attrs[:header] = attrs.delete(:table_header)
        end
        super(attrs)
      end
    end
  end
end
