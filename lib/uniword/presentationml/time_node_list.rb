# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Presentationml
    # Container for time nodes in animation timeline
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:tn_lst>
    class TimeNodeList < Lutaml::Model::Serializable
      attribute :par, ParallelTimeNode, collection: true, initialize_empty: true
      attribute :seq, SequenceTimeNode, collection: true, initialize_empty: true

      xml do
        element 'tn_lst'
        namespace Uniword::Ooxml::Namespaces::PresentationalML
        mixed_content

        map_element 'par', to: :par, render_nil: false
        map_element 'seq', to: :seq, render_nil: false
      end
    end
  end
end
