# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2016
      # Extension list for future extensibility
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:extLst>
      class ExtensionList < Lutaml::Model::Serializable
          attribute :extensions, Extension, collection: true, default: -> { [] }

          xml do
            root 'extLst'
            namespace 'http://schemas.microsoft.com/office/word/2015/wordml', 'w16'
            mixed_content

            map_element 'ext', to: :extensions, render_nil: false
          end
      end
    end
  end
end
