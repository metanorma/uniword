# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # Variant Types (vt: namespace) for OLE property values
      #
      # Used in docProps/custom.xml and docProps/app.xml for typed values.
      # XSD: shared-documentPropertiesVariantTypes.xsd
      # Namespace: http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes
      module VariantTypes
        VT_NS = Uniword::Ooxml::Namespaces::VariantTypes

        # Base class for simple variant type values (text content only)
        class VTValue < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:lpwstr - Wide string (Unicode), most common type
        class VtLpwstr < VTValue
          xml do
            element "lpwstr"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:lpstr - ANSI string
        class VtLpstr < VTValue
          xml do
            element "lpstr"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:bstr - Basic string
        class VtBstr < VTValue
          xml do
            element "bstr"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:i1 - 1-byte signed integer
        class VtI1 < VTValue
          xml do
            element "i1"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:i2 - 2-byte signed integer
        class VtI2 < VTValue
          xml do
            element "i2"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:i4 - 4-byte signed integer
        class VtI4 < VTValue
          xml do
            element "i4"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:i8 - 8-byte signed integer
        class VtI8 < VTValue
          xml do
            element "i8"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:int - Integer
        class VtInt < VTValue
          xml do
            element "int"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:ui1 - 1-byte unsigned integer
        class VtUi1 < VTValue
          xml do
            element "ui1"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:ui2 - 2-byte unsigned integer
        class VtUi2 < VTValue
          xml do
            element "ui2"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:ui4 - 4-byte unsigned integer
        class VtUi4 < VTValue
          xml do
            element "ui4"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:ui8 - 8-byte unsigned integer
        class VtUi8 < VTValue
          xml do
            element "ui8"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:uint - Unsigned integer
        class VtUint < VTValue
          xml do
            element "uint"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:r4 - 4-byte real
        class VtR4 < VTValue
          xml do
            element "r4"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:r8 - 8-byte real
        class VtR8 < VTValue
          xml do
            element "r8"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:decimal - Decimal
        class VtDecimal < VTValue
          xml do
            element "decimal"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:bool - Boolean (text is "0" or "1")
        class VtBool < VTValue
          xml do
            element "bool"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:date - Date/time
        class VtDate < VTValue
          xml do
            element "date"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:filetime - File timestamp
        class VtFiletime < VTValue
          xml do
            element "filetime"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:cy - Currency
        class VtCy < VTValue
          xml do
            element "cy"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:error - Error status code
        class VtError < VTValue
          xml do
            element "error"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:clsid - Class ID (GUID)
        class VtClsid < VTValue
          xml do
            element "clsid"
            namespace VT_NS
            map_content to: :value
          end
        end

        # vt:empty - Empty value (no content)
        class VtEmpty < Lutaml::Model::Serializable
          xml do
            element "empty"
            namespace VT_NS
          end
        end

        # vt:null - Null value (no content)
        class VtNull < Lutaml::Model::Serializable
          xml do
            element "null"
            namespace VT_NS
          end
        end

        # vt:variant - Container for recursive variant
        class VtVariant < Lutaml::Model::Serializable
          attribute :lpwstr, VtLpwstr
          attribute :lpstr, VtLpstr
          attribute :i4, VtI4

          xml do
            element "variant"
            namespace VT_NS

            map_element "lpwstr", to: :lpwstr, render_nil: false
            map_element "lpstr", to: :lpstr, render_nil: false
            map_element "i4", to: :i4, render_nil: false
          end

          def text_value
            lpwstr&.value || lpstr&.value || i4&.value
          end
        end

        # vt:vector - Typed array of values
        class VtVector < Lutaml::Model::Serializable
          attribute :base_type, :string
          attribute :size, :string
          attribute :lpwstr_values, VtLpwstr, collection: true
          attribute :lpstr_values, VtLpstr, collection: true
          attribute :i4_values, VtI4, collection: true
          attribute :variant_values, VtVariant, collection: true

          xml do
            element "vector"
            namespace VT_NS

            map_attribute "baseType", to: :base_type
            map_attribute "size", to: :size
            map_element "lpwstr", to: :lpwstr_values, render_nil: false
            map_element "lpstr", to: :lpstr_values, render_nil: false
            map_element "i4", to: :i4_values, render_nil: false
            map_element "variant", to: :variant_values, render_nil: false
          end

          def values
            lpwstr_values.to_a.map(&:value) +
              lpstr_values.to_a.map(&:value) +
              i4_values.to_a.map(&:value)
          end
        end

        # vt:array - Typed array with bounds
        class VtArray < Lutaml::Model::Serializable
          attribute :base_type, :string
          attribute :size, :string
          attribute :l_bound, :string
          attribute :u_bound, :string

          xml do
            element "array"
            namespace VT_NS

            map_attribute "baseType", to: :base_type
            map_attribute "size", to: :size
            map_attribute "lBound", to: :l_bound
            map_attribute "uBound", to: :u_bound
          end
        end
      end
    end
  end
end
