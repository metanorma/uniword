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

      # DrawingML Chart namespace
      class Chart < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/drawingml/2006/chart'
        prefix_default 'c'
        element_form_default :qualified
      end

      # DrawingML Picture namespace
      class Picture < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/drawingml/2006/picture'
        prefix_default 'pic'
        element_form_default :qualified
      end

      # DrawingML WordProcessing Drawing namespace
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

      # Content Types namespace ([Content_Types].xml)
      class ContentTypes < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/package/2006/content-types'
        prefix_default 'ct'
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

      # Document Variables namespace (docProps/docVars.xml)
      class DocumentVariables < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/docVars'
        prefix_default 'dv'
        element_form_default :qualified
      end

      # Glossary namespace (docProps/glossary.xml)
      class Glossary < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/glossary'
        prefix_default 'g'
        element_form_default :qualified
      end

      # Relationships namespace
      class Relationships < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
        prefix_default 'r'
        element_form_default :qualified
      end

      # Shared Types namespace
      class SharedTypes < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes'
        prefix_default 'st'
        element_form_default :qualified
      end

      # Variant Types namespace
      class VariantTypes < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes'
        prefix_default 'vt'
        element_form_default :qualified
      end

      # Bibliography namespace
      class Bibliography < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/bibliography'
        prefix_default 'b'
        element_form_default :qualified
      end

      # SpreadsheetML namespace
      class SpreadsheetML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
        prefix_default 'xls'
        element_form_default :qualified
      end

      # PresentationalML namespace
      class PresentationalML < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/presentationalml/2006/main'
        prefix_default 'p'
        element_form_default :qualified
      end

      # Word 2010 namespace
      class Word2010 < Lutaml::Model::XmlNamespace
        uri 'http://schemas.microsoft.com/office/word/2010/wordml'
        prefix_default 'w14'
        element_form_default :qualified
      end

      # Word 2012 namespace
      class Word2012 < Lutaml::Model::XmlNamespace
        uri 'http://schemas.microsoft.com/office/word/2012/wordml'
        prefix_default 'w15'
        element_form_default :qualified
      end

      # Word 2015 namespace
      class Word2015 < Lutaml::Model::XmlNamespace
        uri 'http://schemas.microsoft.com/office/word/2015/wordml'
        prefix_default 'w16'
        element_form_default :qualified
      end

      # Custom XML namespace
      class CustomXml < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/customXml'
        prefix_default 'cxml'
        element_form_default :qualified
      end

      # Custom XML namespace
      class CustomXml < Lutaml::Model::XmlNamespace
        uri 'http://schemas.openxmlformats.org/officeDocument/2006/customXml'
        prefix_default 'cxml'
        element_form_default :qualified
      end

      # Office namespace
      class Office < Lutaml::Model::XmlNamespace
        uri 'urn:schemas-microsoft-com:office:office'
        prefix_default 'o'
        element_form_default :qualified
      end

      # VML namespace
      class Vml < Lutaml::Model::XmlNamespace
        uri 'urn:schemas-microsoft-com:vml'
        prefix_default 'v'
        element_form_default :qualified
      end

    end
  end
end