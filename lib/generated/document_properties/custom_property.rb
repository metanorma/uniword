# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentProperties
      # Custom property element
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:property>
      class CustomProperty < Lutaml::Model::Serializable
          attribute :fmtid, String
          attribute :pid, String
          attribute :name, String
          attribute :lpwstr, String
          attribute :i4, String
          attribute :bool, String
          attribute :filetime, String
          attribute :r8, String

          xml do
            root 'property'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties', 'ep'
            mixed_content

            map_attribute 'true', to: :fmtid
            map_attribute 'true', to: :pid
            map_attribute 'true', to: :name
            map_element 'lpwstr', to: :lpwstr, render_nil: false
            map_element 'i4', to: :i4, render_nil: false
            map_element 'bool', to: :bool, render_nil: false
            map_element 'filetime', to: :filetime, render_nil: false
            map_element 'r8', to: :r8, render_nil: false
          end
      end
    end
  end
end
