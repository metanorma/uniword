# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class W15ChartTrackingRefBased < Lutaml::Model::Serializable
      xml do
        element "chartTrackingRefBased"
        namespace Uniword::Ooxml::Namespaces::Word2012
      end
    end
  end
end
