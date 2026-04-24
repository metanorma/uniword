# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates settings consistency.
      #
      # DOC-090: Attached template path check
      # DOC-091: Style IDs in settings match styles.xml
      class SettingsRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-090"
        def category = :settings
        def severity = "info"

        def applicable?(context)
          context.part_exists?("word/settings.xml")
        end

        def check(context)
          issues = []
          settings = context.settings_xml
          return issues unless settings

          # DOC-090: Attached template
          attached = settings.root.at_xpath(".//w:attachedTemplate/@w:val",
                                            "w" => W_NS)
          if attached && !attached.value.empty?
            template_path = attached.value
            if !template_path.start_with?("http") && !File.exist?(template_path)
              issues << issue(
                "Attached template not found: #{template_path}",
                part: "word/settings.xml",
                suggestion: "The template path may be local to the original " \
                            "machine. This is informational and usually harmless.",
              )
            end
          end

          # DOC-091: Settings style IDs vs styles.xml
          check_settings_style_ids(context, settings, issues)

          issues
        end

        private

        def check_settings_style_ids(context, settings, issues)
          return unless context.part_exists?("word/styles.xml")

          defined_ids = context.style_ids

          settings_ids = Set.new
          settings.root.xpath(".//w:style/@w:styleId",
                              "w" => W_NS).each do |attr|
            settings_ids << attr.value
          end

          (settings_ids - defined_ids).each do |id|
            issues << issue(
              "Style '#{id}' referenced in settings.xml but not in styles.xml",
              code: "DOC-091",
              severity: "notice",
              part: "word/settings.xml",
              suggestion: "Add style '#{id}' to styles.xml or remove " \
                          "the reference from settings.",
            )
          end
        end
      end
    end
  end
end
