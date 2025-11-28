# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Properties for smart tag elements
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:smart_tag_properties>
      class SmartTagProperties < Lutaml::Model::Serializable
          attribute :attr, SmartTagAttribute, collection: true, default: -> { [] }

          xml do
            root 'smart_tag_properties'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'
            mixed_content

            map_element 'attr', to: :attr, render_nil: false
          end
      end
    end
  end
end
