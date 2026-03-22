# frozen_string_literal: true

require 'lutaml/model'
require 'lutaml/xml/namespace'
require_relative '../ooxml/namespaces'

module Uniword
  module VmlOffice
    # Office namespace with unqualified attributes for o:shapedefaults element
    # In OOXML, o:shapedefaults belongs to the Office namespace, and its
    # ext/spidmax attributes are unqualified (not prefixed with o:)
    class OfficeNsUnqualified < Lutaml::Xml::Namespace
      uri 'urn:schemas-microsoft-com:office:office'
      prefix_default 'o'
      element_form_default :qualified
      attribute_form_default :unqualified
    end

    # VML namespace for v:ext attribute
    class VmlNsForAttr < Lutaml::Xml::Namespace
      uri 'urn:schemas-microsoft-com:vml'
      prefix_default 'v'
      element_form_default :qualified
      attribute_form_default :qualified
    end

    # v:ext attribute type - in the VML namespace
    class VmlExtType < Lutaml::Model::Type::String
      xml do
        namespace VmlNsForAttr
      end
    end

    # Default shape properties for VML
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:shapedefaults>
    #
    # In OOXML, o:shapedefaults belongs to the Office namespace.
    # The ext attribute is in the VML namespace (v:ext="edit").
    # The spidmax attribute is unqualified in the Office namespace.
    class VmlShapeDefaults < Lutaml::Model::Serializable
      attribute :ext, VmlExtType
      attribute :spidmax, :string

      xml do
        element 'shapedefaults'
        namespace OfficeNsUnqualified
        map_attribute 'ext', to: :ext
        map_attribute 'spidmax', to: :spidmax
      end
    end
  end
end
