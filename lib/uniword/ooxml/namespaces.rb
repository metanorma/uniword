# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    module Namespaces
      # WordProcessingML Main namespace
      # Used for all core Word document elements (paragraphs, runs, tables, etc.)
      class WordProcessingML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
        prefix_default 'w'
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Office Math Markup Language namespace
      # Used for math equations (CRITICAL for ISO documents)
      class MathML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/math'
        prefix_default 'm'
        element_form_default :qualified
      end

      # DrawingML WordProcessing Drawing namespace
      # Used for inline and anchored images
      class WordProcessingDrawing < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing'
        prefix_default 'wp'
        element_form_default :qualified
      end

      # DrawingML Main namespace
      # Used for graphics and shapes
      class DrawingML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/drawingml/2006/main'
        prefix_default 'a'
        element_form_default :qualified
      end

      # Relationships namespace
      # Used for document relationships
      class Relationships < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
        prefix_default 'r'
        element_form_default :qualified
      end

      # VML namespace (legacy)
      # Used for backward compatibility with older Word versions
      class VML < Lutaml::Model::XmlNamespace
        uri 'urn:schemas-microsoft-com:vml'
        prefix_default 'v'
        element_form_default :qualified
      end

      # XML namespace for xml:space attribute
      class XML < Lutaml::Model::XmlNamespace
        uri 'http://www.w3.org/XML/1998/namespace'
        prefix_default 'xml'
        attribute_form_default :unqualified
      end

      # Core Properties namespace (docProps/core.xml)
      class CoreProperties < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties'
        prefix_default 'cp'
        element_form_default :qualified
      end

      # Dublin Core Elements namespace
      class DublinCore < Lutaml::Model::XmlNamespace
        uri 'http://purl.org/dc/elements/1.1/'
        prefix_default 'dc'
        element_form_default :qualified
      end

      # Dublin Core Terms namespace
      class DublinCoreTerms < Lutaml::Model::XmlNamespace
        uri 'http://purl.org/dc/terms/'
        prefix_default 'dcterms'
        element_form_default :qualified
      end

      # XML Schema Instance namespace
      class XmlSchemaInstance < Lutaml::Model::XmlNamespace
        uri 'http://www.w3.org/2001/XMLSchema-instance'
        prefix_default 'xsi'
        attribute_form_default :unqualified
      end

      # Extended Properties namespace (docProps/app.xml)
      class ExtendedProperties < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties'
        prefix_default 'app'
        element_form_default :qualified
      end

      # Variant Types namespace
      class VariantTypes < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes'
        prefix_default 'vt'
        element_form_default :qualified
      end
    end
  end
end