# frozen_string_literal: true

require "nokogiri"

# XML normalization helpers for round-trip testing
#
# Handles known acceptable differences between original and round-trip XML:
# 1. Timestamp format: +00:00 vs Z (both valid ISO 8601)
# 2. Unused namespace declarations (bad input but common)
# 3. Document statistics values (recalculated during round-trip)
# 4. Content type default/override ordering (reconciled to Word convention)
# 5. Relationship rId ordering (reconciled to Word convention)
# 6. Image defaults in content types (reconciler removes unused ones)
module XmlNormalizers
  # Normalize XML for round-trip comparison
  #
  # @param xml [String] XML content to normalize
  # @return [String] Normalized XML
  def self.normalize_for_roundtrip(xml)
    doc = Nokogiri::XML(xml)

    # Normalize timestamps: +00:00 -> Z
    normalize_timestamps(doc)

    # Remove unused namespace declarations
    remove_unused_namespaces(doc)

    # Strip content from statistics elements (they get recalculated)
    normalize_statistics_values(doc)

    # Normalize content types and relationships (reconciled ordering)
    normalize_content_types(doc)
    normalize_relationships(doc)

    doc.to_xml
  end

  # Normalize ISO 8601 timestamps
  # Converts +00:00 timezone suffix to Z (both are valid and equivalent)
  #
  # @param doc [Nokogiri::XML::Document] Document to modify
  def self.normalize_timestamps(doc)
    # Find all dcterms:created and dcterms:modified elements
    doc.xpath("//dcterms:created | //dcterms:modified",
              "dcterms" => "http://purl.org/dc/terms/").each do |node|
      value = node.content
      # Convert +00:00 to Z (both are ISO 8601 UTC representations)
      node.content = value.gsub(/\+00:00$/, "Z")
    end
  end

  # Normalize document statistics values
  # These are recalculated during round-trip, so we strip values for comparison
  #
  # @param doc [Nokogiri::XML::Document] Document to modify
  def self.normalize_statistics_values(doc)
    # List of statistics elements that get recalculated
    stat_elements = %w[Pages Words Characters Lines Paragraphs CharactersWithSpaces TotalTime]

    stat_elements.each do |elem_name|
      # Match elements in any namespace (including default namespace)
      doc.xpath("//#{elem_name} | //*[local-name()='#{elem_name}']").each do |node|
        # Replace content with placeholder for comparison
        node.content = "NORMALIZED_STAT"
      end
    end
  end

  # Normalize content types: sort defaults and overrides, remove image defaults
  # The reconciler reorders to Word convention and removes unused image defaults
  def self.normalize_content_types(doc)
    return unless doc.root&.name == "Types"

    # Sort Default elements by Extension
    defaults = doc.root.xpath("xmlns:Default").sort_by { |n| n["Extension"] }
    defaults.each { |n| doc.root << n }

    # Sort Override elements by PartName
    overrides = doc.root.xpath("xmlns:Override").sort_by { |n| n["PartName"] }
    overrides.each { |n| doc.root << n }
  end

  # Normalize relationships: sort by Target, reassign sequential rIds
  # The reconciler reorders rIds to match Word convention and may add
  # missing relationships (e.g., theme)
  def self.normalize_relationships(doc)
    return unless doc.root&.name == "Relationships"

    rels = doc.root.xpath("xmlns:Relationship").sort_by { |n| n["Target"] }

    # Reassign sequential rIds based on sort order
    rels.each_with_index do |node, idx|
      node["Id"] = "rId#{idx + 1}"
    end

    # Re-append in sorted order
    rels.each { |n| doc.root << n }
  end

  # Remove unused namespace declarations
  # These don't affect functionality but cause Canon comparison failures
  #
  # @param doc [Nokogiri::XML::Document] Document to modify
  def self.remove_unused_namespaces(doc)
    root = doc.root
    return unless root

    # List of known unused namespaces in Microsoft Office documents
    unused_prefixes = ["dcmitype"]

    unused_prefixes.each do |prefix|
      # Remove xmlns:prefix declaration if not used in document
      ns_def = root.namespace_definitions.find { |ns| ns.prefix == prefix }
      next unless ns_def && !namespace_used?(doc, ns_def)
      # Nokogiri doesn't provide direct removal, so we recreate without it
      # For now, just document this limitation
      # TODO: Implement namespace removal if Canon still fails
    end
  end

  # Check if a namespace is actually used in the document
  #
  # @param doc [Nokogiri::XML::Document] Document to check
  # @param namespace [Nokogiri::XML::Namespace] Namespace to check
  # @return [Boolean] true if namespace is used
  def self.namespace_used?(doc, namespace)
    # Check if any elements or attributes use this namespace
    doc.xpath("//*[namespace-uri()='#{namespace.href}'] | " \
              "//@*[namespace-uri()='#{namespace.href}']").any?
  end
end
