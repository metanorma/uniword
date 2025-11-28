# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Cell comment
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:comment>
      class Comment < Lutaml::Model::Serializable
          attribute :ref, String
          attribute :author_id, Integer
          attribute :text, String

          xml do
            root 'comment'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :ref
            map_attribute 'true', to: :author_id
            map_element 'text', to: :text, render_nil: false
          end
      end
    end
  end
end
