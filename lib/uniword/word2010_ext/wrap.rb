# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Word2010Ext
    # Word 2010 extensibility wrap element
    # Used inside VML shapes for Word 2010 specific wrapping
    #
    # Element: <w10:wrap>
    # Namespace: urn:schemas-microsoft-com:office:word
    class Wrap < Lutaml::Model::Serializable
      attribute :anchorx, :string
      attribute :anchory, :string

      xml do
        element 'wrap'
        namespace Uniword::Ooxml::Namespaces::Word2010Ext
        mixed_content

        map_attribute 'anchorx', to: :anchorx, render_nil: false
        map_attribute 'anchory', to: :anchory, render_nil: false
      end
    end
  end
end
