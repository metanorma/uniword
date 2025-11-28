# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # List of extensions for future extensibility
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:ext_lst>
      class ExtensionList < Lutaml::Model::Serializable
          attribute :ext, Extension, collection: true, default: -> { [] }

          xml do
            root 'ext_lst'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'ext', to: :ext, render_nil: false
          end
      end
    end
  end
end
