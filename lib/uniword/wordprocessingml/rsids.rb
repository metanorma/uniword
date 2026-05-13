# frozen_string_literal: true

require "lutaml/model"
require_relative "rsid_root"
require_relative "rsid"

module Uniword
  module Wordprocessingml
    class Rsids < Lutaml::Model::Serializable
      attribute :rsid_root, RsidRoot
      attribute :rsid, Rsid, collection: true

      xml do
        element "rsids"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "rsidRoot", to: :rsid_root, render_nil: false
        map_element "rsid", to: :rsid, render_nil: false
      end
    end
  end
end
