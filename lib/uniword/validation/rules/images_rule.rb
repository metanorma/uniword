# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates image/media references.
      #
      # DOC-050: Image relationship targets exist in word/media/
      # DOC-051: Image content types match file extensions
      # DOC-052: blip embed references resolve to image parts
      class ImagesRule < Base
        R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
        A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"

        IMAGE_TYPES = %w[
          image/png image/jpeg image/gif image/tiff
          image/bmp image/svg+xml image/emf image/wmf
        ].freeze

        def code = "DOC-050"
        def category = :images
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/document.xml")
        end

        def check(context)
          issues = []
          rels = context.relationships
          rels_by_id = rels.to_h { |r| [r[:id], r] }

          # DOC-050: Image relationship targets
          image_rels = rels.select { |r| r[:type]&.include?("image") }
          image_rels.each do |rel|
            target = rel[:target]
            next unless target

            target_path = target.start_with?("/") ? target[1..] : "word/#{target}"

            next if context.part_exists?(target_path)

            issues << issue(
              "Image target '#{target_path}' not found in package",
              part: "word/_rels/document.xml.rels",
              suggestion: "Add the image file '#{target_path}' to the " \
                          "package, or remove the relationship.",
            )
          end

          # DOC-051: Content type consistency
          check_image_content_types(context, image_rels, issues)

          # DOC-052: blip embed references
          check_blip_refs(context, rels_by_id, issues)

          issues
        end

        private

        def check_image_content_types(context, image_rels, issues)
          ct = context.content_types
          image_rels.each do |rel|
            target = rel[:target]
            next unless target

            ext = File.extname(target)[1..]
            next unless ext

            declared = ct[ext] || ct["/#{target.start_with?('/') ? target[1..] : "word/#{target}"}"]

            next unless declared && IMAGE_TYPES.none? do |_t|
              declared.include?(ext.upcase)
            end

            issues << issue(
              "Image extension '.#{ext}' has non-image content type: #{declared}",
              code: "DOC-051",
              severity: "warning",
              part: "[Content_Types].xml",
              suggestion: "Set the content type for '.#{ext}' to an image " \
                          "MIME type (e.g., image/#{ext}).",
            )
          end
        end

        def check_blip_refs(context, rels_by_id, issues)
          raw = context.part_raw("word/document.xml")
          return unless raw

          doc = Nokogiri::XML(raw)
          doc.xpath("//a:blip", "a" => A_NS).each do |blip|
            embed = blip["r:embed"] ||
              blip.attributes.find { |a| a.name == "embed" }&.value
            next unless embed

            rel = rels_by_id[embed]
            next if rel

            issues << issue(
              "blip r:embed='#{embed}' not found in relationships",
              code: "DOC-052",
              part: "word/document.xml",
              suggestion: "Add a relationship for r:id='#{embed}' " \
                          "pointing to the image.",
            )
          end
        end
      end
    end
  end
end
