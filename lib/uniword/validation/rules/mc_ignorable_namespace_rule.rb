# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates that mc:Ignorable namespace prefixes have xmlns declarations.
      #
      # DOC-100: mc:Ignorable lists prefixes that must have xmlns in scope
      # Validity rule: R1
      class McIgnorableNamespaceRule < Base
        MC_NS = "http://schemas.openxmlformats.org/markup-compatibility/2006"

        def code = "DOC-100"
        def validity_rule = "R1"
        def description = "mc:Ignorable prefixes must have xmlns declarations in scope"
        def category = :namespaces
        def severity = "error"

        PARTS = [
          "word/document.xml",
          "word/styles.xml",
          "word/settings.xml",
          "word/numbering.xml",
          "word/fontTable.xml",
          "word/webSettings.xml",
        ].freeze

        def applicable?(context)
          PARTS.any? { |p| context.part_exists?(p) }
        end

        def check(context)
          issues = []

          PARTS.each do |part_name|
            next unless context.part_exists?(part_name)

            doc = context.part(part_name)
            next unless doc

            root = doc.root
            next unless root

            ignorable_attr = root.attribute("Ignorable") ||
                             root.attributes.find { |a| a.name == "Ignorable" }
            next unless ignorable_attr && !ignorable_attr.value.strip.empty?

            prefixes = ignorable_attr.value.strip.split(/\s+/)
            check_prefixes(root, prefixes, part_name, issues)
          end

          issues
        end

        private

        def check_prefixes(root, prefixes, part_name, issues)
          declared = extract_declared_prefixes(root)
          prefixes.each do |prefix|
            next if declared.include?(prefix)

            issues << issue(
              "mc:Ignorable prefix '#{prefix}' has no xmlns declaration in scope " \
              "in #{part_name}",
              part: part_name,
              suggestion: "Add xmlns:#{prefix} to the root element, " \
                          "or remove '#{prefix}' from mc:Ignorable.",
            )
          end
        end

        def extract_declared_prefixes(root)
          root.namespaces.each_with_object(Set.new) do |ns, set|
            set << ns.prefix if ns.prefix
          end
        end
      end
    end
  end
end
