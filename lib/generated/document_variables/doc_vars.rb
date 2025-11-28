# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentVariables
      # Container for document variables used for substitution
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:doc_vars>
      class DocVars < Lutaml::Model::Serializable
          attribute :doc_var, DocVar, collection: true, default: -> { [] }

          xml do
            root 'doc_vars'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/docVars', 'dv'
            mixed_content

            map_element 'docVar', to: :doc_var, render_nil: false
          end
      end
    end
  end
end
