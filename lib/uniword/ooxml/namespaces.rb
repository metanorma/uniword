# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Namespaces
      # WordProcessingML Main namespace
      # Used for all core Word document elements (paragraphs, runs, tables, etc.)
      class WordProcessingML < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        prefix_default "w"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Office Math Markup Language namespace
      # Used for math equations (CRITICAL for ISO documents)
      class MathML < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/math"
        prefix_default "m"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # DrawingML WordProcessing Drawing namespace
      # Used for inline and anchored images
      class WordProcessingDrawing < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
        prefix_default "wp"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # DrawingML Chart namespace
      class Chart < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/drawingml/2006/chart"
        prefix_default "c"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # DrawingML Diagram (SmartArt) namespace
      class Diagram < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/drawingml/2006/diagram"
        prefix_default "dgm"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # DrawingML Picture namespace
      class Picture < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/drawingml/2006/picture"
        prefix_default "pic"
        element_form_default :qualified
        attribute_form_default :unqualified
      end

      # DrawingML Main namespace
      # Used for graphics and shapes
      # NOTE: DrawingML attributes are UNQUALIFIED (no prefix)
      class DrawingML < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/drawingml/2006/main"
        prefix_default "a"
        element_form_default :qualified
        attribute_form_default :unqualified
      end

      # Relationships namespace
      # Used for document relationships
      class Relationships < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
        prefix_default "r"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # XML namespace for xml:space attribute
      class XML < Lutaml::Xml::Namespace
        uri "http://www.w3.org/XML/1998/namespace"
        prefix_default "xml"
        attribute_form_default :unqualified
      end

      # Core Properties namespace (docProps/core.xml)
      class CoreProperties < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
        prefix_default "cp"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Content Types namespace ([Content_Types].xml)
      class ContentTypes < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/package/2006/content-types"
        prefix_default "ct"
        element_form_default :qualified
        attribute_form_default :unqualified
      end

      # Dublin Core Elements namespace
      class DublinCore < Lutaml::Xml::Namespace
        uri "http://purl.org/dc/elements/1.1/"
        prefix_default "dc"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Dublin Core Terms namespace
      class DublinCoreTerms < Lutaml::Xml::Namespace
        uri "http://purl.org/dc/terms/"
        prefix_default "dcterms"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Dublin Core MIType namespace
      class DublinCoreMitype < Lutaml::Xml::Namespace
        uri "http://purl.org/dc/dcmitype/"
        prefix_default "dcmitype"
      end

      # XML Schema Instance namespace
      class XmlSchemaInstance < Lutaml::Xml::Namespace
        uri "http://www.w3.org/2001/XMLSchema-instance"
        prefix_default "xsi"
        attribute_form_default :unqualified
      end

      # Extended Properties namespace (docProps/app.xml)
      class ExtendedProperties < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
        prefix_default "app"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Document Variables namespace (docProps/docVars.xml)
      class DocumentVariables < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/docVars"
        prefix_default "dv"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Glossary namespace (docProps/glossary.xml)
      class Glossary < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/glossary"
        prefix_default "g"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Package-level Relationships namespace (_rels/.rels)
      class PackageRelationships < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/package/2006/relationships"
        prefix_default "rel"
        element_form_default :qualified
        attribute_form_default :unqualified
      end

      # Shared Types namespace
      class SharedTypes < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes"
        prefix_default "st"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Variant Types namespace
      class VariantTypes < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes"
        prefix_default "vt"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Bibliography namespace
      class Bibliography < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/bibliography"
        prefix_default "b"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # SpreadsheetML namespace
      class SpreadsheetML < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
        prefix_default "xls"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # PresentationalML namespace
      class PresentationalML < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/presentationalml/2006/main"
        prefix_default "p"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2010 namespace
      class Word2010 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2010/wordml"
        prefix_default "w14"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Drawing 2010 namespace (used by a14: prefix)
      class Drawing2010 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2010/main"
        prefix_default "a14"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2012 namespace
      class Word2012 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2012/wordml"
        prefix_default "w15"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2015 namespace
      class Word2015 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2015/wordml"
        prefix_default "w16"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2016 namespace
      class Word2016 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2016/wordml"
        prefix_default "w16"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2016 CID namespace (citation identifiers)
      class Word2016Cid < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2016/wordml/cid"
        prefix_default "w16cid"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Custom XML namespace
      class CustomXml < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/customXml"
        prefix_default "cxml"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Office namespace
      class Office < Lutaml::Xml::Namespace
        uri "urn:schemas-microsoft-com:office:office"
        prefix_default "o"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # VML namespace
      class Vml < Lutaml::Xml::Namespace
        uri "urn:schemas-microsoft-com:vml"
        prefix_default "v"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Markup Compatibility namespace
      # Used for forward compatibility (Ignorable attribute)
      class MarkupCompatibility < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/markup-compatibility/2006"
        prefix_default "mc"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # ThemeML namespace (Office 2013+)
      # Used for theme family metadata in theme extensions
      class ThemeML < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/thememl/2012/main"
        prefix_default "thm15"
        element_form_default :qualified
        attribute_form_default :unqualified
      end

      # WordprocessingShape namespace
      # Used for VML-compatible shapes in DrawingML
      class WordprocessingShape < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
        prefix_default "wps"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # WordprocessingGroup namespace
      # Used for shape groups in DrawingML
      class WordprocessingGroup < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
        prefix_default "wpg"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # VML Word namespace
      # Used for VML elements within Word documents (borders, etc.)
      # Prefix "w10" avoids collision with WordProcessingML prefix "w"
      class VmlWord < Lutaml::Xml::Namespace
        uri "urn:schemas-microsoft-com:office:word"
        prefix_default "w10"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Custom Properties namespace (docProps/custom.xml)
      class CustomProperties < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
        prefix_default "custprops"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Additional Characteristics namespace
      class Characteristics < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/officeDocument/2006/characteristics"
        prefix_default "ac"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Schema Library namespace
      class SchemaLibrary < Lutaml::Xml::Namespace
        uri "http://schemas.openxmlformats.org/schemaLibrary/2006/main"
        prefix_default "sl"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # === Additional namespaces for Word 2024 compatibility ===

      # Wordprocessing Canvas namespace
      class WordprocessingCanvas < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
        prefix_default "wpc"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # ChartEx namespace (base)
      class ChartEx < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2014/chartex"
        prefix_default "cx"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # ChartEx variant namespaces (1-8)
      class ChartEx1 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2015/9/8/chartex"
        prefix_default "cx1"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      class ChartEx2 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2015/10/21/chartex"
        prefix_default "cx2"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      class ChartEx3 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2016/5/9/chartex"
        prefix_default "cx3"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      class ChartEx4 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2016/5/10/chartex"
        prefix_default "cx4"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      class ChartEx5 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2016/5/11/chartex"
        prefix_default "cx5"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      class ChartEx6 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2016/5/12/chartex"
        prefix_default "cx6"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      class ChartEx7 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2016/5/13/chartex"
        prefix_default "cx7"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      class ChartEx8 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2016/5/14/chartex"
        prefix_default "cx8"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Ink Drawing namespace
      class InkDrawing < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2016/ink"
        prefix_default "aink"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # 3D Model namespace
      class Model3D < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/drawing/2017/model3d"
        prefix_default "am3d"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Office Extension List namespace
      class OfficeExtensionList < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/2019/extlst"
        prefix_default "oel"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2010 Wordprocessing Drawing namespace (wp14)
      class Word2010Drawing < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
        prefix_default "wp14"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2018 namespace (w16 in Word 2024 output)
      class Word2018 < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2018/wordml"
        prefix_default "w16"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2018 CEX namespace
      class Word2018Cex < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2018/wordml/cex"
        prefix_default "w16cex"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2023 DU namespace
      class Word2023Du < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2023/wordml/word16du"
        prefix_default "w16du"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2020 SDT Data Hash namespace
      class Word2020SdtDataHash < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2020/wordml/sdtdatahash"
        prefix_default "w16sdtdh"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2024 SDT Format Lock namespace
      class Word2024SdtFormatLock < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2024/wordml/sdtformatlock"
        prefix_default "w16sdtfl"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word 2015 Symex namespace
      class Word2015Symex < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2015/wordml/symex"
        prefix_default "w16se"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Wordprocessing Ink namespace
      class WordprocessingInk < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
        prefix_default "wpi"
        element_form_default :qualified
        attribute_form_default :qualified
      end

      # Word Numbering Equations namespace
      class WordNumberingEquations < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/word/2006/wordml"
        prefix_default "wne"
        element_form_default :qualified
        attribute_form_default :qualified
      end
    end
  end
end
