# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Paragraph-level formatting properties
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:p_pr>
      class ParagraphProperties < Lutaml::Model::Serializable
          attribute :algn, :string
          attribute :lvl, :integer
          attribute :marL, :integer
          attribute :marR, :integer
          attribute :indent, :integer

          xml do
            root 'p_pr'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'algn', to: :algn
            map_attribute 'lvl', to: :lvl
            map_attribute 'marL', to: :marL
            map_attribute 'marR', to: :marR
            map_attribute 'indent', to: :indent
          end
      end
    end
  end
end
