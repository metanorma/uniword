# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Presentationml
      # Container for notes master identifiers
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:notes_master_id_lst>
      class NotesMasterIdList < Lutaml::Model::Serializable
          attribute :notes_master_id, :string

          xml do
            element 'notes_master_id_lst'
            namespace Uniword::Ooxml::Namespaces::PresentationalML

            map_attribute 'notesMasterId', to: :notes_master_id
          end
      end
    end
end
