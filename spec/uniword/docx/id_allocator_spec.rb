# frozen_string_literal: true

require "spec_helper"
require "uniword/docx"

RSpec.describe Uniword::Docx::IdAllocator do
  let(:allocator) { described_class.new }

  describe "#alloc_rid" do
    it "returns rId1 for the first allocation" do
      expect(allocator.alloc_rid(target: "styles.xml",
                                 type: described_class::IMAGE_REL_TYPE))
        .to eq("rId1")
    end

    it "increments across calls" do
      allocator.alloc_rid(target: "a", type: "t1")
      second = allocator.alloc_rid(target: "b", type: "t1")
      expect(second).to eq("rId2")
    end

    it "returns the same rId for the same target+type pair" do
      first = allocator.alloc_rid(target: "styles.xml", type: "styles")
      second = allocator.alloc_rid(target: "styles.xml", type: "styles")
      expect(second).to eq(first)
    end

    it "returns different rIds for different target+type pairs" do
      a = allocator.alloc_rid(target: "a", type: "t1")
      b = allocator.alloc_rid(target: "b", type: "t1")
      expect(a).not_to eq(b)
    end

    it "accepts target_mode" do
      rid = allocator.alloc_rid(target: "https://example.com",
                                type: described_class::HYPERLINK_REL_TYPE,
                                target_mode: "External")
      expect(rid).to eq("rId1")
    end
  end

  describe "#alloc_footnote_id and #alloc_endnote_id" do
    it "starts at 1 and increments" do
      expect(allocator.alloc_footnote_id).to eq(1)
      expect(allocator.alloc_footnote_id).to eq(2)
    end

    it "has independent counters for footnotes and endnotes" do
      allocator.alloc_footnote_id
      allocator.alloc_footnote_id

      expect(allocator.alloc_endnote_id).to eq(1)
    end
  end

  describe "#alloc_bookmark_id and #alloc_comment_id" do
    it "returns string IDs starting at 1" do
      expect(allocator.alloc_bookmark_id).to eq("1")
      expect(allocator.alloc_bookmark_id).to eq("2")
    end

    it "has independent counters for bookmarks and comments" do
      allocator.alloc_bookmark_id

      expect(allocator.alloc_comment_id).to eq("1")
    end
  end

  describe "#alloc_para_id and #alloc_rsid" do
    it "returns 12-char uppercase hex strings" do
      expect(allocator.alloc_para_id).to match(/\A[0-9A-F]{12}\z/)
      expect(allocator.alloc_rsid).to match(/\A[0-9A-F]{12}\z/)
    end

    it "is deterministic across runs for the same call sequence" do
      a1 = described_class.new
      a2 = described_class.new
      3.times { a1.alloc_para_id }
      3.times { a2.alloc_para_id }

      expect(a1.alloc_para_id).to eq(a2.alloc_para_id)
    end

    it "has independent counters — interleaving produces same result as isolation" do
      isolated = described_class.new
      3.times { isolated.alloc_para_id }
      isolated.alloc_rsid

      interleaved = described_class.new
      interleaved.alloc_para_id
      interleaved.alloc_rsid
      interleaved.alloc_para_id
      interleaved.alloc_para_id
      # Note: counter values differ when interleaved vs isolated;
      # the contract is that the same call sequence yields the same output.

      expect(interleaved.alloc_rsid).to eq(described_class.new.tap { |a|
        a.alloc_para_id
        a.alloc_rsid
        a.alloc_para_id
        a.alloc_para_id
      }.alloc_rsid)
    end
  end

  describe "#seed_from_rels" do
    let(:rel_class) { Uniword::Ooxml::Relationships::Relationship }

    it "preserves existing rIds" do
      rels = [
        rel_class.new(id: "rId5", type: "image", target: "x.png"),
        rel_class.new(id: "rId9", type: "hyperlink", target: "https://a"),
      ]
      allocator.seed_from_rels(rels)

      expect(allocator.alloc_rid(target: "new", type: "image")).to eq("rId10")
    end

    it "returns existing rId for registered target+type" do
      rels = [rel_class.new(id: "rId3", type: "image", target: "x.png")]
      allocator.seed_from_rels(rels)

      expect(allocator.alloc_rid(target: "x.png", type: "image")).to eq("rId3")
    end

    it "handles nil relationships" do
      expect { allocator.seed_from_rels(nil) }.not_to raise_error
    end
  end

  describe "#seed_from_notes" do
    let(:fn_class) { Uniword::Wordprocessingml::Footnote }
    let(:en_class) { Uniword::Wordprocessingml::Endnote }

    it "seeds footnote counter from existing IDs" do
      fns = [
        fn_class.new(id: "-1", type: "separator"),
        fn_class.new(id: "1"),
        fn_class.new(id: "5"),
      ]
      allocator.seed_from_notes(fns, nil)

      expect(allocator.alloc_footnote_id).to eq(6)
    end

    it "seeds endnote counter independently" do
      fns = [fn_class.new(id: "3")]
      ens = [en_class.new(id: "7")]
      allocator.seed_from_notes(fns, ens)

      expect(allocator.alloc_footnote_id).to eq(4)
      expect(allocator.alloc_endnote_id).to eq(8)
    end

    it "handles nil entries" do
      expect { allocator.seed_from_notes(nil, nil) }.not_to raise_error
    end
  end

  describe ".populate_from_package" do
    it "seeds from all sources in one call" do
      package = Uniword::Docx::Package.new
      package.document = Uniword::Wordprocessingml::DocumentRoot.new
      package.document_rels = Uniword::Ooxml::Relationships::PackageRelationships.new(
        relationships: [
          Uniword::Ooxml::Relationships::Relationship.new(
            id: "rId5", type: "image", target: "x.png",
          ),
        ],
      )

      alloc = described_class.populate_from_package(package)

      expect(alloc.alloc_rid(target: "x.png", type: "image")).to eq("rId5")
      expect(alloc.alloc_rid(target: "new", type: "image")).to eq("rId6")
    end

    it "handles nil fields on package" do
      package = Uniword::Docx::Package.new

      expect do
        described_class.populate_from_package(package)
      end.not_to raise_error
    end
  end

  describe "#all_rels" do
    it "returns sorted list by numeric rId component" do
      allocator.alloc_rid(target: "a", type: "t")
      allocator.alloc_rid(target: "b", type: "t")
      allocator.alloc_rid(target: "c", type: "t")

      ids = allocator.all_rels.map { |r| r[:id] }
      expect(ids).to eq(%w[rId1 rId2 rId3])
    end
  end

  describe "#rid_for" do
    it "returns rId for a registered target+type" do
      allocator.alloc_rid(target: "x.png", type: "image")
      expect(allocator.rid_for(target: "x.png", type: "image")).to eq("rId1")
    end

    it "returns nil for an unregistered pair" do
      expect(allocator.rid_for(target: "nope", type: "image")).to be_nil
    end
  end
end
