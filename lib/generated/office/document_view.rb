# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Document view settings
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:view>
      class DocumentView < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'view'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
