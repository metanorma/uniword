# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Typed attribute classes for w14/w15/w16 namespace attributes
    # In lutaml-model 0.9.0+, namespace is declared in the xml block, not in map_attribute

    # W14 namespace for Word 2010 elements and attributes
    W14_NAMESPACE = Uniword::Ooxml::Namespaces::Word2010

    # W15 namespace for Word 2012 elements and attributes
    W15_NAMESPACE = Uniword::Ooxml::Namespaces::Word2012

    # W16CID namespace for Word 2016+ citation identifiers
    W16CID_NAMESPACE = Uniword::Ooxml::Namespaces::Word2016Cid

    # Typed attribute for w14:paraId
    class W14ParaId < Lutaml::Model::Type::String
      xml do
        namespace W14_NAMESPACE
      end
    end

    # Typed attribute for w14:textId
    class W14TextId < Lutaml::Model::Type::String
      xml do
        namespace W14_NAMESPACE
      end
    end

    # Typed attribute for w15:restartNumberingAfterBreak
    class W15RestartNumberingAfterBreak < Lutaml::Model::Type::Integer
      xml do
        namespace W15_NAMESPACE
      end
    end

    # Typed attribute for w16cid:durableId
    class W16CidDurableId < Lutaml::Model::Type::String
      xml do
        namespace W16CID_NAMESPACE
      end
    end
  end
end
