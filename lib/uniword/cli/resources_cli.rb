# frozen_string_literal: true

require "thor"
require_relative "helpers"

module Uniword
  # Word Resources subcommands for Uniword CLI.
  #
  # Exports raw Word resources (.thmx themes, .dotx stylesets) from a
  # local Microsoft Word installation to a target directory.
  class ResourcesCLI < Thor
    include CLIHelpers

    desc "export OUTPUT_DIR", "Export Word resources from local Microsoft Word installation"
    long_desc <<~DESC
      Export raw Word resources (.thmx themes, .dotx stylesets) from the
      local Microsoft Word installation to a target directory.

      Examples:
        $ uniword resources export output/ --word-app "/Applications/Microsoft Word.app"
    DESC
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean, default: false
    option :word_app, aliases: "-w", desc: "Path to Microsoft Word.app", type: :string,
                      required: true, banner: "PATH"
    def export(output_dir)
      word_app_path = options[:word_app]
      validate_word_app(word_app_path)

      resources_path = File.join(word_app_path, "Contents", "Resources")
      output_base = output_dir || "uniword-private/word-resources"

      export_office_themes(resources_path, output_base)
      export_quick_styles(resources_path, output_base)
      export_document_elements(resources_path, output_base)
      export_citation_styles(resources_path, output_base)
      export_theme_colors(resources_path, output_base)
      export_theme_fonts(resources_path, output_base)

      say "\nWord resources exported to #{output_base}", :green
    rescue StandardError => e
      say "Error: #{e.message}", :red
      exit 1
    end

    private

    def validate_word_app(path)
      unless path
        say "--word-app is required", :red
        exit 1
      end

      unless File.exist?(path)
        say "Microsoft Word not found at: #{path}", :red
        exit 1
      end

      unless File.directory?(path)
        say "#{path} is not a directory (expected path to Microsoft Word.app)", :red
        exit 1
      end
    end

    def export_office_themes(resources_path, output_base)
      themes_path = File.join(resources_path, "Office Themes")
      return say("No themes found in Word installation", :yellow) unless Dir.exist?(themes_path)

      themes_dir = File.join(output_base, "office-themes")
      count = copy_glob("#{themes_path}/*.thmx", themes_dir)
      say "Exported #{count} themes to #{themes_dir}", :green
    end

    def export_quick_styles(resources_path, output_base)
      stylesets_path = File.join(resources_path, "QuickStyles")
      return say("No QuickStyles found in Word installation", :yellow) unless Dir.exist?(stylesets_path)

      styles_dir = File.join(output_base, "quick-styles")
      count = copy_glob("#{stylesets_path}/*.dotx", styles_dir)
      say "Exported #{count} stylesets to #{styles_dir}", :green
    end

    def export_document_elements(resources_path, output_base)
      lproj_count = 0
      elements_count = 0
      elements_dir = File.join(output_base, "document-elements")

      Dir.glob("#{resources_path}/*.lproj").each do |lproj|
        doc_elements_path = File.join(lproj, "Document Elements")
        next unless Dir.exist?(doc_elements_path)

        lproj_name = File.basename(lproj, ".lproj")
        lproj_elements_dir = File.join(elements_dir, lproj_name)
        FileUtils.mkdir_p(lproj_elements_dir)
        Dir.glob("#{doc_elements_path}/*.dotx").each do |dotx|
          FileUtils.cp(dotx, lproj_elements_dir)
          say "  #{lproj_name}: #{File.basename(dotx)}" if options[:verbose]
          elements_count += 1
        end
        lproj_count += 1
      end

      if elements_count.positive?
        say "Exported #{elements_count} document elements from #{lproj_count} languages to #{elements_dir}",
            :green
      else
        say "No Document Elements found in Word installation", :yellow
      end
    end

    def export_citation_styles(resources_path, output_base)
      path = File.join(resources_path, "Style")
      return say("No citation styles found in Word installation", :yellow) unless Dir.exist?(path)

      dir = File.join(output_base, "citation-styles")
      count = copy_glob("#{path}/*.xsl", dir)
      say "Exported #{count} citation styles to #{dir}", :green
    end

    def export_theme_colors(resources_path, output_base)
      path = File.join(resources_path, "Office Themes", "Theme Colors")
      return say("No theme colors found in Word installation", :yellow) unless Dir.exist?(path)

      dir = File.join(output_base, "theme-colors")
      count = copy_glob("#{path}/*.xml", dir)
      say "Exported #{count} theme colors to #{dir}", :green
    end

    def export_theme_fonts(resources_path, output_base)
      path = File.join(resources_path, "Office Themes", "Theme Fonts")
      return say("No theme fonts found in Word installation", :yellow) unless Dir.exist?(path)

      dir = File.join(output_base, "theme-fonts")
      count = copy_glob("#{path}/*.xml", dir)
      say "Exported #{count} theme fonts to #{dir}", :green
    end

    def copy_glob(pattern, dest_dir)
      FileUtils.mkdir_p(dest_dir)
      files = Dir.glob(pattern)
      files.each do |f|
        FileUtils.cp(f, dest_dir)
        say "  Copied #{File.basename(f)}" if options[:verbose]
      end
      files.count
    end
  end
end
