# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Docx.js Compatibility: Hyperlinks", :compatibility do
  describe "External Hyperlinks" do
    describe "basic hyperlink creation" do
      it "should support adding hyperlinks to text" do
        doc = Uniword::Document.new

        doc.add_paragraph do |para|
          para.add_run("Anchor Text") do |run|
            run.hyperlink = "http://www.example.com"
          end
        end

        para = doc.paragraphs.first
        run = para.runs.first
        expect(run.hyperlink).to eq("http://www.example.com")
        expect(run.text).to eq("Anchor Text")
      end

      it "should support hyperlinks with custom text style" do
        skip "Hyperlink style customization not yet implemented"

        doc = Uniword::Document.new

        doc.add_paragraph do |para|
          para.add_run("Styled Link") do |run|
            run.hyperlink = "http://www.example.com"
            run.style = "Hyperlink"
          end
        end

        run = doc.paragraphs.first.runs.first
        expect(run.style).to eq("Hyperlink")
      end

      it "should support multiple hyperlinks in one paragraph" do
        doc = Uniword::Document.new

        doc.add_paragraph do |para|
          para.add_run("Visit ")
          para.add_run("Example") do |run|
            run.hyperlink = "http://www.example.com"
          end
          para.add_run(" or ")
          para.add_run("BBC News") do |run|
            run.hyperlink = "https://www.bbc.co.uk/news"
          end
        end

        para = doc.paragraphs.first
        hyperlink_runs = para.runs.select { |r| r.hyperlink }
        expect(hyperlink_runs.count).to eq(2)
        expect(hyperlink_runs[0].hyperlink).to eq("http://www.example.com")
        expect(hyperlink_runs[1].hyperlink).to eq("https://www.bbc.co.uk/news")
      end
    end

    describe "hyperlinks with formatting" do
      it "should support formatted text within hyperlinks" do
        skip "Formatted hyperlinks not yet fully implemented"

        doc = Uniword::Document.new

        doc.add_paragraph do |para|
          para.add_run("This is a hyperlink with formatting: ")

          # Hyperlink with multiple formatted runs
          para.add_hyperlink("http://www.example.com") do |link|
            link.add_run("A ")
            link.add_run("single ") { |r| r.bold = true }
            link.add_run("link") { |r| r.double_strike = true }
            link.add_run("1") { |r| r.superscript = true }
            link.add_run("!")
          end
        end

        para = doc.paragraphs.first
        # Verify hyperlink contains formatted content
        expect(para.runs.any? { |r| r.hyperlink }).to be true
      end

      it "should support bold hyperlinks" do
        doc = Uniword::Document.new

        doc.add_paragraph do |para|
          para.add_run("Bold Link") do |run|
            run.hyperlink = "http://www.example.com"
            run.bold = true
          end
        end

        run = doc.paragraphs.first.runs.first
        expect(run.bold).to be true
        expect(run.hyperlink).to eq("http://www.example.com")
      end

      it "should support underlined hyperlinks" do
        skip "Underline customization for hyperlinks not yet implemented"

        doc = Uniword::Document.new

        doc.add_paragraph do |para|
          para.add_run("Underlined Link") do |run|
            run.hyperlink = "http://www.example.com"
            run.underline = { type: "single", color: "0000FF" }
          end
        end

        run = doc.paragraphs.first.runs.first
        expect(run.underline).to be_truthy
      end
    end

    describe "hyperlinks in headers and footers" do
      it "should support hyperlinks in headers" do
        skip "Headers and footers not yet fully implemented"

        doc = Uniword::Document.new

        doc.header.add_paragraph do |para|
          para.add_run("Click here for the ")
          para.add_run("Header external hyperlink") do |run|
            run.hyperlink = "http://www.google.com"
            run.style = "Hyperlink"
          end
        end

        header_para = doc.header.paragraphs.first
        hyperlink_run = header_para.runs.find { |r| r.hyperlink }
        expect(hyperlink_run).not_to be_nil
        expect(hyperlink_run.hyperlink).to eq("http://www.google.com")
      end

      it "should support hyperlinks in footers" do
        skip "Headers and footers not yet fully implemented"

        doc = Uniword::Document.new

        doc.footer.add_paragraph do |para|
          para.add_run("Click here for the ")
          para.add_run("Footer external hyperlink") do |run|
            run.hyperlink = "http://www.example.com"
            run.style = "Hyperlink"
          end
        end

        footer_para = doc.footer.paragraphs.first
        hyperlink_run = footer_para.runs.find { |r| r.hyperlink }
        expect(hyperlink_run).not_to be_nil
        expect(hyperlink_run.hyperlink).to eq("http://www.example.com")
      end
    end

    describe "hyperlinks with images" do
      it "should support image hyperlinks" do
        skip "Image hyperlinks not yet implemented"

        doc = Uniword::Document.new

        doc.add_paragraph do |para|
          para.add_image("path/to/image.jpeg") do |img|
            img.hyperlink = "http://www.google.com"
            img.width = 100
            img.height = 100
          end
        end

        para = doc.paragraphs.first
        img = para.images.first
        expect(img.hyperlink).to eq("http://www.google.com")
      end
    end

    describe "hyperlinks in footnotes" do
      it "should support hyperlinks within footnotes" do
        skip "Footnotes not yet fully implemented"

        doc = Uniword::Document.new

        # Add footnote with hyperlink
        doc.add_footnote(id: 1) do |footnote|
          footnote.add_paragraph do |para|
            para.add_run("Click here for the ")
            para.add_run("Footnotes external hyperlink") do |run|
              run.hyperlink = "http://www.example.com"
              run.style = "Hyperlink"
            end
          end
        end

        # Add paragraph with footnote reference
        doc.add_paragraph do |para|
          para.add_run("See footnote ")
          para.add_footnote_reference(1)
        end

        footnote = doc.footnotes[1]
        expect(footnote).not_to be_nil
        hyperlink_run = footnote.paragraphs.first.runs.find { |r| r.hyperlink }
        expect(hyperlink_run.hyperlink).to eq("http://www.example.com")
      end
    end

    describe "hyperlink style configuration" do
      it "should support custom hyperlink style colors" do
        skip "Custom hyperlink styles not yet implemented"

        doc = Uniword::Document.new do |d|
          d.styles.hyperlink do |style|
            style.color = "FF0000"  # Red
            style.underline_color = "0000FF"  # Blue underline
          end
        end

        doc.add_paragraph do |para|
          para.add_run("Red Link") do |run|
            run.hyperlink = "http://www.example.com"
            run.style = "Hyperlink"
          end
        end

        # Verify style was configured
        expect(doc.styles.hyperlink.color).to eq("FF0000")
      end
    end
  end

  describe "Internal Hyperlinks" do
    describe "bookmark linking" do
      it "should support internal bookmarks" do
        skip "Bookmark hyperlinks not yet implemented"

        doc = Uniword::Document.new

        # Create a bookmark
        doc.add_paragraph("Section 1") do |para|
          para.bookmark = "section1"
        end

        # Link to the bookmark
        doc.add_paragraph do |para|
          para.add_run("Go to ")
          para.add_run("Section 1") do |run|
            run.internal_link = "#section1"
          end
        end

        bookmark_para = doc.paragraphs.first
        link_para = doc.paragraphs.last

        expect(bookmark_para.bookmark).to eq("section1")
        link_run = link_para.runs.find { |r| r.internal_link }
        expect(link_run.internal_link).to eq("#section1")
      end
    end

    describe "cross-references" do
      it "should support heading cross-references" do
        skip "Cross-references not yet implemented"

        doc = Uniword::Document.new

        doc.add_paragraph("Introduction", heading: :heading_1)

        doc.add_paragraph do |para|
          para.add_run("See ")
          para.add_cross_reference(type: :heading, target: "Introduction")
        end

        # Verify cross-reference
        para = doc.paragraphs.last
        expect(para.cross_references).not_to be_empty
      end
    end
  end

  describe "Round-trip preservation" do
    it "should preserve hyperlinks when reading and writing" do
      skip "Round-trip testing requires full implementation"

      # Create document with hyperlink
      original = Uniword::Document.new
      original.add_paragraph do |para|
        para.add_run("Link") do |run|
          run.hyperlink = "http://www.example.com"
        end
      end

      # Save and reload
      temp_path = "/tmp/hyperlink_test.docx"
      original.save(temp_path)
      reloaded = Uniword::Document.open(temp_path)

      # Verify hyperlink preserved
      run = reloaded.paragraphs.first.runs.first
      expect(run.hyperlink).to eq("http://www.example.com")
    end
  end

  describe "URL validation" do
    it "should accept valid HTTP URLs" do
      doc = Uniword::Document.new

      doc.add_paragraph do |para|
        para.add_run("Link") do |run|
          run.hyperlink = "http://www.example.com"
        end
      end

      expect(doc.paragraphs.first.runs.first.hyperlink).to match(%r{^http://})
    end

    it "should accept valid HTTPS URLs" do
      doc = Uniword::Document.new

      doc.add_paragraph do |para|
        para.add_run("Secure Link") do |run|
          run.hyperlink = "https://www.example.com"
        end
      end

      expect(doc.paragraphs.first.runs.first.hyperlink).to match(%r{^https://})
    end

    it "should accept mailto links" do
      skip "Mailto links validation not yet implemented"

      doc = Uniword::Document.new

      doc.add_paragraph do |para|
        para.add_run("Email") do |run|
          run.hyperlink = "mailto:user@example.com"
        end
      end

      expect(doc.paragraphs.first.runs.first.hyperlink).to match(/^mailto:/)
    end
  end
end