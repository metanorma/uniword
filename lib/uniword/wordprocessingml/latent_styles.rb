# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Latent styles exception entry
    # Must be defined BEFORE LatentStyles since it's referenced in the attribute declaration
    #
    # Element: <w:lsdException>
    class LatentStylesException < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :ui_priority, :integer
      attribute :q_format, :boolean
      attribute :semi_hidden, :boolean
      attribute :unhide_when_used, :boolean
      attribute :locked, :boolean

      xml do
        element 'lsdException'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'name', to: :name
        map_attribute 'uiPriority', to: :ui_priority
        map_attribute 'qFormat', to: :q_format
        map_attribute 'semiHidden', to: :semi_hidden
        map_attribute 'unhideWhenUsed', to: :unhide_when_used
        map_attribute 'locked', to: :locked
      end
    end

    # Latent style information
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:latentStyles>
    class LatentStyles < Lutaml::Model::Serializable
      attribute :def_locked_state, :boolean
      attribute :def_ui_priority, :integer
      attribute :def_semi_hidden, :boolean
      attribute :def_unhide_when_used, :boolean
      attribute :def_q_format, :boolean
      attribute :count, :integer
      attribute :lsd_exception, LatentStylesException, collection: true

      xml do
        element 'latentStyles'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'defLockedState', to: :def_locked_state
        map_attribute 'defUIPriority', to: :def_ui_priority
        map_attribute 'defSemiHidden', to: :def_semi_hidden
        map_attribute 'defUnhideWhenUsed', to: :def_unhide_when_used
        map_attribute 'defQFormat', to: :def_q_format
        map_attribute 'count', to: :count
        map_element 'lsdException', to: :lsd_exception, render_nil: false
      end
    end
  end
end
