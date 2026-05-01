# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates settings.xml value formats.
      #
      # DOC-101: w15:docId must be GUID format, w14:docId must be hex string
      # Validity rule: R2
      class SettingsValuesRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        W15_NS = "http://schemas.microsoft.com/office/word/2012/wordml"
        W14_NS = "http://schemas.microsoft.com/office/word/2010/wordml"
        GUID_RE = /\A\{[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\}\z/
        HEX8_RE = /\A[0-9A-Fa-f]{8}\z/

        def code = "DOC-101"
        def validity_rule = "R2"
        def description = "Settings value formats (w15:docId GUID, w14:docId hex)"
        def category = :settings
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/settings.xml")
        end

        def check(context)
          issues = []
          doc = context.settings_xml
          return issues unless doc

          check_w15_doc_id(doc, issues)
          check_w14_doc_id(doc, issues)

          issues
        end

        private

        def check_w15_doc_id(doc, issues)
          node = doc.root.at_xpath(".//w15:docId/@w:val", "w15" => W15_NS, "w" => W_NS)
          return unless node

          val = node.value
          return if val.match?(GUID_RE)

          issues << issue(
            "w15:docId value '#{val}' is not GUID format " \
            "(expected {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX})",
            part: "word/settings.xml",
            suggestion: "Use GUID format: \"{#{SecureRandom.uuid.upcase}}\"",
          )
        end

        def check_w14_doc_id(doc, issues)
          node = doc.root.at_xpath(".//w14:docId/@w:val", "w14" => W14_NS, "w" => W_NS)
          return unless node

          val = node.value
          return if val.match?(HEX8_RE)

          issues << issue(
            "w14:docId value '#{val}' is not 8-char hex format",
            part: "word/settings.xml",
            severity: "warning",
            suggestion: "Use 8-character hex string format.",
          )
        end
      end
    end
  end
end
