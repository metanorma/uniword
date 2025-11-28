# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Run properties applied to the end of a paragraph
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:end_para_r_pr>
      class EndParagraphRunProperties < Lutaml::Model::Serializable
          attribute :lang, :string
          attribute :sz, :integer
          attribute :b, :string

          xml do
            root 'end_para_r_pr'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'

            map_attribute 'lang', to: :lang
            map_attribute 'sz', to: :sz
            map_attribute 'b', to: :b
          end
      end
    end
  end
end
