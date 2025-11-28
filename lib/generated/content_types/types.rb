# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module ContentTypes
      # Content types root element for [Content_Types].xml
      #
      # Generated from OOXML schema: content_types.yml
      # Element: <ct:Types>
      class Types < Lutaml::Model::Serializable
          attribute :defaults, Default, collection: true, default: -> { [] }
          attribute :overrides, Override, collection: true, default: -> { [] }

          xml do
            root 'Types'
            namespace 'http://schemas.openxmlformats.org/package/2006/content-types', 'ct'
            mixed_content

            map_element 'Default', to: :defaults, render_nil: false
            map_element 'Override', to: :overrides, render_nil: false
          end
      end
    end
  end
end
