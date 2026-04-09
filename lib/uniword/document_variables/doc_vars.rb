# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentVariables
    # Container for document variables used for substitution
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:doc_vars>
    class DocVars < Lutaml::Model::Serializable
      attribute :doc_var, DocVar, collection: true, initialize_empty: true

      xml do
        element 'doc_vars'
        namespace Uniword::Ooxml::Namespaces::DocumentVariables
        mixed_content

        map_element 'docVar', to: :doc_var, render_nil: false
      end
    end
  end
end
