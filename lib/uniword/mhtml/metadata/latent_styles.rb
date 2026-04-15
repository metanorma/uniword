# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Mhtml
    module Metadata
      # w:LatentStyles — latent style definitions from MHTML.
      #
      # Has attributes and potentially hundreds of LsdException children.
      # For round-tripping, we store the raw XML.
      class LatentStyles < Lutaml::Model::Serializable
        attribute :def_locked_state, :string
        attribute :def_unhide_when_used, :string
        attribute :def_semi_hidden, :string
        attribute :def_q_format, :string
        attribute :def_priority, :string
        attribute :latent_style_count, :string

        xml do
          element "LatentStyles"
          namespace Uniword::Mhtml::Namespaces::Word
          map_attribute "DefLockedState", to: :def_locked_state
          map_attribute "DefUnhideWhenUsed", to: :def_unhide_when_used
          map_attribute "DefSemiHidden", to: :def_semi_hidden
          map_attribute "DefQFormat", to: :def_q_format
          map_attribute "DefPriority", to: :def_priority
          map_attribute "LatentStyleCount", to: :latent_style_count
        end
      end
    end
  end
end
