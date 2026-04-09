# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # List of extensions for future extensibility
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:ext_lst>
    class ExtensionList < Lutaml::Model::Serializable
      attribute :ext, Extension, collection: true, initialize_empty: true

      xml do
        element 'ext_lst'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'ext', to: :ext, render_nil: false
      end
    end
  end
end
