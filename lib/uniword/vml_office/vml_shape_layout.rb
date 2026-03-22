# frozen_string_literal: true

require 'lutaml/model'
require 'lutaml/xml/namespace'
require_relative '../ooxml/namespaces'

module Uniword
  module VmlOffice
    # Office namespace with unqualified attributes (for o:shapelayout and o:idmap)
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

    # ID map element
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:idmap>
    #
    # In OOXML, o:idmap belongs to the Office namespace.
    # The v:ext attribute uses the VML namespace.
    # The data attribute is unqualified.
    class VmlIdmap < Lutaml::Model::Serializable
      attribute :ext, VmlExtType
      attribute :data, :string

      xml do
        element 'idmap'
        namespace OfficeNsUnqualified
        map_attribute 'ext', to: :ext
        map_attribute 'data', to: :data
      end
    end

    # Shape layout settings
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:shapelayout>
    #
    # In OOXML, o:shapelayout belongs to the Office namespace.
    # The v:ext attribute uses the VML namespace.
    class VmlShapeLayout < Lutaml::Model::Serializable
      attribute :ext, VmlExtType
      attribute :idmap, VmlIdmap

      xml do
        element 'shapelayout'
        namespace OfficeNsUnqualified
        map_attribute 'ext', to: :ext
        map_element 'idmap', to: :idmap, render_nil: false
      end
    end
  end
end
