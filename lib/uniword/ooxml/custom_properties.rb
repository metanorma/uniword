# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    # Custom Document Properties (docProps/custom.xml)
    #
    # XSD: shared-documentPropertiesCustom.xsd
    # Namespace: http://schemas.openxmlformats.org/officeDocument/2006/custom-properties
    #
    # Each property has a name, fmtid (GUID), pid (int), and exactly one
    # vt:* value element (lpwstr, i4, bool, etc.).
    #
    # @example Parse from XML
    #   props = CustomProperties.from_xml(xml_string)
    #   props.properties.first.name  # => "AssetID"
    #   props.properties.first.value # => "TF10002067"
    #
    # @example Create programmatically
    #   props = CustomProperties.new
    #   props.properties << CustomProperty.new(
    #     fmtid: "{D5CDD505-2E9C-101B-9397-08002B2CF9AE}",
    #     pid: 2,
    #     name: "Department",
    #     lpwstr: Types::VariantTypes::VtLpwstr.new(value: "Engineering")
    #   )
    class CustomProperty < Lutaml::Model::Serializable
      attribute :fmtid, :string
      attribute :pid, :integer
      attribute :name, :string
      attribute :link_target, :string

      # Variant type values - only one should be set per XSD choice
      attribute :lpwstr, Types::VariantTypes::VtLpwstr
      attribute :lpstr, Types::VariantTypes::VtLpstr
      attribute :bstr, Types::VariantTypes::VtBstr
      attribute :i1, Types::VariantTypes::VtI1
      attribute :i2, Types::VariantTypes::VtI2
      attribute :i4, Types::VariantTypes::VtI4
      attribute :i8, Types::VariantTypes::VtI8
      attribute :int, Types::VariantTypes::VtInt
      attribute :ui1, Types::VariantTypes::VtUi1
      attribute :ui2, Types::VariantTypes::VtUi2
      attribute :ui4, Types::VariantTypes::VtUi4
      attribute :ui8, Types::VariantTypes::VtUi8
      attribute :uint, Types::VariantTypes::VtUint
      attribute :r4, Types::VariantTypes::VtR4
      attribute :r8, Types::VariantTypes::VtR8
      attribute :decimal, Types::VariantTypes::VtDecimal
      attribute :bool, Types::VariantTypes::VtBool
      attribute :date, Types::VariantTypes::VtDate
      attribute :filetime, Types::VariantTypes::VtFiletime
      attribute :cy, Types::VariantTypes::VtCy
      attribute :error, Types::VariantTypes::VtError
      attribute :clsid, Types::VariantTypes::VtClsid
      attribute :empty, Types::VariantTypes::VtEmpty
      attribute :null, Types::VariantTypes::VtNull
      attribute :vector, Types::VariantTypes::VtVector
      attribute :array, Types::VariantTypes::VtArray

      xml do
        element "property"
        namespace Namespaces::CustomProperties

        map_attribute "fmtid", to: :fmtid
        map_attribute "pid", to: :pid
        map_attribute "name", to: :name
        map_attribute "linkTarget", to: :link_target

        map_element "lpwstr", to: :lpwstr, render_nil: false
        map_element "lpstr", to: :lpstr, render_nil: false
        map_element "bstr", to: :bstr, render_nil: false
        map_element "i1", to: :i1, render_nil: false
        map_element "i2", to: :i2, render_nil: false
        map_element "i4", to: :i4, render_nil: false
        map_element "i8", to: :i8, render_nil: false
        map_element "int", to: :int, render_nil: false
        map_element "ui1", to: :ui1, render_nil: false
        map_element "ui2", to: :ui2, render_nil: false
        map_element "ui4", to: :ui4, render_nil: false
        map_element "ui8", to: :ui8, render_nil: false
        map_element "uint", to: :uint, render_nil: false
        map_element "r4", to: :r4, render_nil: false
        map_element "r8", to: :r8, render_nil: false
        map_element "decimal", to: :decimal, render_nil: false
        map_element "bool", to: :bool, render_nil: false
        map_element "date", to: :date, render_nil: false
        map_element "filetime", to: :filetime, render_nil: false
        map_element "cy", to: :cy, render_nil: false
        map_element "error", to: :error, render_nil: false
        map_element "clsid", to: :clsid, render_nil: false
        map_element "empty", to: :empty, render_nil: false
        map_element "null", to: :null, render_nil: false
        map_element "vector", to: :vector, render_nil: false
        map_element "array", to: :array, render_nil: false
      end

      # Get the value from whichever variant type is set
      def value
        lpwstr&.value || lpstr&.value || bstr&.value ||
          i4&.value || i8&.value || i2&.value || i1&.value || int&.value ||
          ui4&.value || ui8&.value || ui2&.value || ui1&.value || uint&.value ||
          r4&.value || r8&.value || decimal&.value ||
          bool&.value || date&.value || filetime&.value ||
          cy&.value || error&.value || clsid&.value
      end

      # Check if any variant type value is set
      def has_value?
        !!value || !!empty || !!null || !!vector || !!array
      end
    end

    # Root element for docProps/custom.xml
    class CustomProperties < Lutaml::Model::Serializable
      attribute :properties, CustomProperty, collection: true,
                                             initialize_empty: true

      xml do
        element "Properties"
        namespace Namespaces::CustomProperties

        namespace_scope [
          { namespace: Namespaces::VariantTypes, declare: :always },
        ]

        map_element "property", to: :properties, render_nil: false
      end
    end
  end
end
