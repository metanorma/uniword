# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Mhtml
    # XML namespaces used in MHTML documents.
    #
    # MHTML uses legacy Microsoft Office XML namespaces (urn:schemas-microsoft-com:*)
    # which are DIFFERENT from the OOXML namespaces (schemas.openxmlformats.org).
    module Namespaces
      # Legacy Office namespace (o:) — DocumentProperties, OfficeDocumentSettings
      class Office < Lutaml::Xml::Namespace
        uri "urn:schemas-microsoft-com:office:office"
        prefix_default "o"
      end

      # Legacy Word namespace (w:) — WordDocument, LatentStyles
      class Word < Lutaml::Xml::Namespace
        uri "urn:schemas-microsoft-com:office:word"
        prefix_default "w"
      end

      # Office Math namespace (m:) — mathPr
      class Math < Lutaml::Xml::Namespace
        uri "http://schemas.microsoft.com/office/2004/12/omml"
        prefix_default "m"
      end
    end
  end
end
