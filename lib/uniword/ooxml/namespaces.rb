# frozen_string_literal: true

require 'lutaml/model'
require 'lutaml/model/xml_namespace'

module Uniword
  module Ooxml
    module Namespaces
      # WordProcessingML Main namespace
      # Used for all core Word document elements (paragraphs, runs, tables, etc.)
      class WordProcessingML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        prefix_default 'w'
        element_form_default :qualified
        attribute_form_default :unqualified
        documentation "WordProcessingML Main Namespace - ISO 29500"
      end

      # Office Math Markup Language namespace
      # Used for math equations (CRITICAL for ISO documents)
      class MathML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/math'
        prefix_default 'm'
        element_form_default :qualified
        documentation "Office Math Markup Language"
      end

      # DrawingML WordProcessing Drawing namespace
      # Used for inline and anchored images
      class WordProcessingDrawing < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing'
        prefix_default 'wp'
        element_form_default :qualified
        documentation "DrawingML WordProcessing Drawing"
      end

      # DrawingML Main namespace
      # Used for graphics and shapes
      class DrawingML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/drawingml/2006/main'
        prefix_default 'a'
        element_form_default :qualified
        documentation "DrawingML Main"
      end

      # Relationships namespace
      # Used for document relationships
      class Relationships < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
        prefix_default 'r'
        element_form_default :qualified
        documentation "Office Document Relationships"
      end

      # VML namespace (legacy)
      # Used for backward compatibility with older Word versions
      class VML < Lutaml::Model::XmlNamespace
        uri 'urn:schemas-microsoft-com:vml'
        prefix_default 'v'
        element_form_default :qualified
        documentation "Vector Markup Language (Legacy)"
      end

      # XML namespace for xml:space attribute
      class XML < Lutaml::Model::XmlNamespace
        uri 'http://www.w3.org/XML/1998/namespace'
        prefix_default 'xml'
        attribute_form_default :unqualified
        documentation "W3C XML Namespace"
      end

      # Core Properties namespace (docProps/core.xml)
      class CoreProperties < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties'
        prefix_default 'cp'
        element_form_default :qualified
        documentation "Package Core Properties"
      end

      # Dublin Core Elements namespace
      class DublinCore < Lutaml::Model::XmlNamespace
        uri 'http://purl.org/dc/elements/1.1/'
        prefix_default 'dc'
        element_form_default :qualified
        documentation "Dublin Core Metadata Element Set"
      end

      # Dublin Core Terms namespace
      class DublinCoreTerms < Lutaml::Model::XmlNamespace
        uri 'http://purl.org/dc/terms/'
        prefix_default 'dcterms'
        element_form_default :qualified
        documentation "Dublin Core Metadata Terms"
      end

      # XML Schema Instance namespace
      class XmlSchemaInstance < Lutaml::Model::XmlNamespace
        uri 'http://www.w3.org/2001/XMLSchema-instance'
        prefix_default 'xsi'
        attribute_form_default :unqualified
        documentation "XML Schema Instance"
      end

      # Extended Properties namespace (docProps/app.xml)
      class ExtendedProperties < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties'
        prefix_default 'app'
        element_form_default :qualified
        documentation "Extended Application Properties"
      end

      # Variant Types namespace
      class VariantTypes < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes'
        prefix_default 'vt'
        element_form_default :qualified
        documentation "Document Properties Variant Types"
      end
    end
  end
end