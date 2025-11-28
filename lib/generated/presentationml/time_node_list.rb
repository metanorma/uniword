# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Container for time nodes in animation timeline
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:tn_lst>
      class TimeNodeList < Lutaml::Model::Serializable
          attribute :par, ParallelTimeNode, collection: true, default: -> { [] }
          attribute :seq, SequenceTimeNode, collection: true, default: -> { [] }

          xml do
            root 'tn_lst'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'par', to: :par, render_nil: false
            map_element 'seq', to: :seq, render_nil: false
          end
      end
    end
  end
end
