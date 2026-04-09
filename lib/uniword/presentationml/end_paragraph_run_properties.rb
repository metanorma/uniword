# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
        element 'end_para_r_pr'
        namespace Uniword::Ooxml::Namespaces::PresentationalML

        map_attribute 'lang', to: :lang
        map_attribute 'sz', to: :sz
        map_attribute 'b', to: :b
      end
    end
  end
end
