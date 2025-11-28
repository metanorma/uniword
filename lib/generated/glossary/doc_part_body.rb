# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Glossary
      # Body content of a document part (building block content)
      #
      # Generated from OOXML schema: glossary.yml
      # Element: <g:doc_part_body>
      class DocPartBody < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            root 'doc_part_body'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/glossary', 'g'
            mixed_content

            map_element 'content', to: :content, render_nil: false
          end
      end
    end
  end
end
