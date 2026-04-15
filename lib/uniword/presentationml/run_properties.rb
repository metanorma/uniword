# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Presentationml
    # Character-level formatting properties
    #
    # Generated from OOXML schema: presentationml.yml
    # Element: <p:r_pr>
    class RunProperties < Lutaml::Model::Serializable
      attribute :lang, :string
      attribute :sz, :integer
      attribute :b, :string
      attribute :i, :string
      attribute :u, :string
      attribute :strike, :string
      attribute :baseline, :integer

      xml do
        element "r_pr"
        namespace Uniword::Ooxml::Namespaces::PresentationalML

        map_attribute "lang", to: :lang
        map_attribute "sz", to: :sz
        map_attribute "b", to: :b
        map_attribute "i", to: :i
        map_attribute "u", to: :u
        map_attribute "strike", to: :strike
        map_attribute "baseline", to: :baseline
      end
    end
  end
end
