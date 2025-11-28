# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Container for handout master identifiers
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:handout_master_id_lst>
      class HandoutMasterIdList < Lutaml::Model::Serializable
          attribute :handout_master_id, :string

          xml do
            root 'handout_master_id_lst'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'handoutMasterId', to: :handout_master_id
          end
      end
    end
  end
end
