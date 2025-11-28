# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Description text for a document part
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_description>
      class DocPartDescription < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'doc_part_description'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
