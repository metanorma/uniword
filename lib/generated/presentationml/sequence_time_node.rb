# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Time node for sequential animation execution
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:seq>
      class SequenceTimeNode < Lutaml::Model::Serializable
          attribute :c_tn, CommonTimeNode
          attribute :prev_cond_lst, :string
          attribute :next_cond_lst, :string

          xml do
            root 'seq'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'cTn', to: :c_tn
            map_element 'prevCondLst', to: :prev_cond_lst, render_nil: false
            map_element 'nextCondLst', to: :next_cond_lst, render_nil: false
          end
      end
    end
  end
end
