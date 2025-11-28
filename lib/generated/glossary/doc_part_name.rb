# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Name of a document part
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_name>
      class DocPartName < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'doc_part_name'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
