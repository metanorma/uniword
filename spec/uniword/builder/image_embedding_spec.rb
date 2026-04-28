# frozen_string_literal: true

require "spec_helper"
require "securerandom"

RSpec.describe "Image Embedding, Bibliography, Charts" do
  # =========================================================================
  # 16A: DocxPackage Image Embedding
  # =========================================================================

  describe "DocxPackage image embedding" do
    let(:sample_png) { "spec/fixtures/sample.png" }

    # Helper: build ZIP content hash for a document model
    def zip_content_for(model)
      pkg = Uniword::Docx::Package.new
      pkg.document = model
      Uniword::Docx::Package.copy_document_parts_to_package(model, pkg)
      pkg.content_types ||= Uniword::Docx::Package.minimal_content_types
      pkg.document_rels ||= Uniword::Docx::Package.minimal_document_rels
      pkg.to_zip_content
    end

    it "embeds image binary data in the ZIP content" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.image(sample_png)

      content = zip_content_for(doc.model)
      expect(content.keys).to include(match(%r{word/media/}))
    end

    it "adds image content type for PNG" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.image(sample_png)

      content = zip_content_for(doc.model)
      ct = content["[Content_Types].xml"]
      expect(ct).to include("image/png")
    end

    it "adds image relationship to document rels" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.image(sample_png)

      content = zip_content_for(doc.model)
      rels = content["word/_rels/document.xml.rels"]
      expect(rels).to include("image")
      expect(rels).to include("media/")
    end

    it "preserves image data encoding (binary)" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.image(sample_png)

      content = zip_content_for(doc.model)
      media_key = content.keys.find { |k| k.include?("media/") }
      expect(media_key).not_to be_nil
      expect(content[media_key].encoding).to eq(Encoding::ASCII_8BIT)
    end

    it "handles multiple images" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.image(sample_png)
      doc.image(sample_png)

      content = zip_content_for(doc.model)
      media_keys = content.keys.select { |k| k.include?("media/") }
      expect(media_keys.size).to be >= 1
    end

    it "saves DOCX with images that can be read back" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Image Test")
      doc.image(sample_png)

      path = "/tmp/test_image_embed.docx"
      doc.save(path)

      expect(File.exist?(path)).to be(true)

      require "zip"
      Zip::File.open(path) do |zip|
        media_entries = zip.glob("word/media/*")
        expect(media_entries.size).to be >= 1
      end

      safe_rm_f(path)
    end
  end

  # =========================================================================
  # 16B: BibliographyBuilder
  # =========================================================================

  describe "BibliographyBuilder" do
    let(:builder) { Uniword::Builder::BibliographyBuilder.new }

    describe "initialization" do
      it "creates a Sources model with default APA style" do
        expect(builder.sources).to be_a(Uniword::Bibliography::Sources)
        expect(builder.sources.selected_style).to eq("APA")
      end

      it "accepts custom style" do
        bib = Uniword::Builder::BibliographyBuilder.new(style: "MLA")
        expect(bib.sources.selected_style).to eq("MLA")
      end
    end

    describe "book" do
      it "creates a book source with all fields" do
        builder.book(
          tag: "Smith2024",
          author: ["John Smith"],
          title: "The Great Book",
          year: "2024",
          publisher: "ACME Press",
          city: "New York",
          edition: "3rd",
        )

        src = builder.sources.source.first
        expect(src.source_type).to eq("Book")
        expect(src.tag).to eq("Smith2024")
        expect(src.title).to eq("The Great Book")
        expect(src.year).to eq("2024")
        expect(src.publisher).to eq("ACME Press")
        expect(src.city).to eq("New York")
        expect(src.edition).to eq("3rd")
        expect(src.ref_order).to eq("1")
      end

      it "creates author with first and last name" do
        builder.book(
          tag: "Doe2023",
          author: ["Jane Doe"],
          title: "A Book",
          year: "2023",
          publisher: "Pub",
        )

        src = builder.sources.source.first
        expect(src.author).not_to be_nil
        expect(src.author.name_list).not_to be_nil
        person = src.author.name_list.person.first
        expect(person.first).to eq("Jane")
        expect(person.last).to eq("Doe")
      end

      it "handles multiple authors" do
        builder.book(
          tag: "Multi2024",
          author: ["Alice Smith", "Bob Jones"],
          title: "Collaboration",
          year: "2024",
          publisher: "Pub",
        )

        src = builder.sources.source.first
        expect(src.author.name_list.person.size).to eq(2)
        expect(src.author.name_list.person[0].last).to eq("Smith")
        expect(src.author.name_list.person[1].last).to eq("Jones")
      end
    end

    describe "journal" do
      it "creates a journal article source" do
        builder.journal(
          tag: "Doe2023",
          author: ["Jane Doe"],
          title: "Important Discovery",
          year: "2023",
          journal: "Nature",
          volume: "42",
          issue: "5",
          pages: "100-110",
        )

        src = builder.sources.source.first
        expect(src.source_type).to eq("JournalArticle")
        expect(src.publisher).to eq("Nature")
        expect(src.volume).to eq("42")
        expect(src.issue).to eq("5")
        expect(src.pages).to eq("100-110")
      end
    end

    describe "website" do
      it "creates a website source" do
        builder.website(
          tag: "Web2024",
          title: "Example Page",
          url: "https://example.com",
          year: "2024",
        )

        src = builder.sources.source.first
        expect(src.source_type).to eq("InternetSite")
        expect(src.url).to eq("https://example.com")
      end

      it "handles website with author" do
        builder.website(
          tag: "AuthWeb",
          title: "Authored Page",
          url: "https://example.com",
          author: ["John Smith"],
        )

        src = builder.sources.source.first
        expect(src.author.name_list.person.first.last).to eq("Smith")
      end
    end

    describe "conference" do
      it "creates a conference proceedings source" do
        builder.conference(
          tag: "Conf2024",
          author: ["Alice Smith"],
          title: "My Paper",
          year: "2024",
          publisher: "ACM",
          city: "Berlin",
        )

        src = builder.sources.source.first
        expect(src.source_type).to eq("ConferenceProceedings")
        expect(src.city).to eq("Berlin")
      end
    end

    describe "source (generic)" do
      it "creates a source with custom type" do
        builder.source(
          tag: "Generic1",
          source_type: "Report",
          title: "Annual Report",
          year: "2024",
          url: "https://example.com/report",
        )

        src = builder.sources.source.first
        expect(src.source_type).to eq("Report")
        expect(src.url).to eq("https://example.com/report")
      end
    end

    describe "style=" do
      it "changes the citation style" do
        builder.style = "Chicago"
        expect(builder.sources.selected_style).to eq("Chicago")
      end
    end

    describe "attach" do
      it "attaches sources to a DocumentBuilder" do
        doc = Uniword::Builder::DocumentBuilder.new
        builder.book(
          tag: "Test1", author: ["Author"], title: "Test",
          year: "2024", publisher: "Pub"
        )
        builder.attach(doc)

        expect(doc.model.bibliography_sources).to eq(builder.sources)
      end

      it "attaches sources to a DocumentRoot directly" do
        root = Uniword::Wordprocessingml::DocumentRoot.new
        builder.book(
          tag: "Test1", author: ["Author"], title: "Test",
          year: "2024", publisher: "Pub"
        )
        builder.attach(root)

        expect(root.bibliography_sources).to eq(builder.sources)
      end
    end

    describe "build" do
      it "returns the Sources model" do
        expect(builder.build).to be_a(Uniword::Bibliography::Sources)
      end
    end

    describe "serialization" do
      it "serializes sources to XML" do
        builder.book(
          tag: "Smith2024",
          author: ["John Smith"],
          title: "The Book",
          year: "2024",
          publisher: "ACME",
        )

        xml = builder.build.to_xml(encoding: "UTF-8", declaration: true)
        expect(xml).to include("Smith2024")
        expect(xml).to include("The Book")
        expect(xml).to include("Book")
        expect(xml).to include("John")
        expect(xml).to include("Smith")
      end

      it "serializes multiple sources" do
        builder.book(
          tag: "Smith2024", author: ["John"], title: "Book1",
          year: "2024", publisher: "Pub"
        )
        builder.journal(
          tag: "Doe2023", author: ["Jane"], title: "Article",
          year: "2023", journal: "Nature"
        )

        xml = builder.build.to_xml
        expect(xml).to include("Smith2024")
        expect(xml).to include("Doe2023")
      end
    end

    describe "DocumentBuilder integration" do
      it "creates bibliography via DocumentBuilder" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.bibliography(style: "APA") do |bib|
          bib.book(
            tag: "Test1", author: ["Author"], title: "Test Book",
            year: "2024", publisher: "Publisher"
          )
        end

        expect(doc.model.bibliography_sources).not_to be_nil
        expect(doc.model.bibliography_sources.source.size).to eq(1)
      end

      it "creates bibliography placeholder" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.bibliography_placeholder

        last_para = doc.model.body.paragraphs.last
        expect(last_para.sdts).not_to be_empty
      end

      it "saves DOCX with bibliography sources" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.bibliography do |bib|
          bib.book(
            tag: "Smith2024", author: ["John Smith"],
            title: "The Book", year: "2024", publisher: "ACME"
          )
        end

        path = "/tmp/test_bibliography.docx"
        doc.save(path)

        expect(File.exist?(path)).to be(true)

        require "zip"
        Zip::File.open(path) do |zip|
          expect(zip.find_entry("word/sources.xml")).not_to be_nil
          sources_xml = zip.read("word/sources.xml")
          expect(sources_xml).to include("Smith2024")
          expect(sources_xml).to include("The Book")
        end

        safe_rm_f(path)
      end
    end
  end

  # =========================================================================
  # 16C: ChartBuilder
  # =========================================================================

  describe "ChartBuilder" do
    let(:builder) { Uniword::Builder::ChartBuilder.new }

    describe "initialization" do
      it "defaults to bar chart type" do
        expect(builder.chart_type).to eq(:bar)
      end

      it "accepts custom chart type" do
        cb = Uniword::Builder::ChartBuilder.new(chart_type: :pie)
        expect(cb.chart_type).to eq(:pie)
      end
    end

    describe "title" do
      it "sets the chart title" do
        builder.title("Sales Report")
        expect(builder.title_text).to eq("Sales Report")
      end
    end

    describe "categories" do
      it "sets category labels" do
        builder.categories(%w[Q1 Q2 Q3 Q4])
        expect(builder.categories).to eq(%w[Q1 Q2 Q3 Q4])
      end
    end

    describe "series" do
      it "adds a data series" do
        builder.series("Revenue", data: [100, 200, 150])
        expect(builder.series_list.size).to eq(1)
        expect(builder.series_list[0][:name]).to eq("Revenue")
        expect(builder.series_list[0][:data]).to eq([100, 200, 150])
      end

      it "adds multiple series" do
        builder.series("Revenue", data: [100, 200])
        builder.series("Costs", data: [80, 120])
        expect(builder.series_list.size).to eq(2)
      end
    end

    describe "legend" do
      it "configures legend visibility and position" do
        builder.legend(show: false)
        expect(builder.instance_variable_get(:@show_legend)).to be(false)
      end
    end

    describe "dimensions" do
      it "sets chart dimensions" do
        builder.dimensions(width: 4_000_000, height: 3_000_000)
        expect(builder.instance_variable_get(:@width)).to eq(4_000_000)
        expect(builder.instance_variable_get(:@height)).to eq(3_000_000)
      end
    end

    describe "build_xml" do
      it "produces valid chart XML for bar chart" do
        builder.title("Test Chart")
        builder.categories(%w[A B C])
        builder.series("Series 1", data: [10, 20, 30])

        xml = builder.build_xml
        expect(xml).to include("chartSpace")
        expect(xml).to include("Test Chart")
        expect(xml).to include("barChart")
        expect(xml).to include("Series 1")
      end

      it "produces valid chart XML for line chart" do
        cb = Uniword::Builder::ChartBuilder.new(chart_type: :line)
        cb.title("Line Test")
        cb.categories(%w[X1 X2])
        cb.series("Data", data: [1, 2])

        xml = cb.build_xml
        expect(xml).to include("lineChart")
        expect(xml).to include("Line Test")
      end

      it "produces valid chart XML for pie chart" do
        cb = Uniword::Builder::ChartBuilder.new(chart_type: :pie)
        cb.title("Pie Test")
        cb.categories(%w[A B C])
        cb.series("Share", data: [45, 30, 25])

        xml = cb.build_xml
        expect(xml).to include("pieChart")
        expect(xml).to include("Pie Test")
      end

      it "includes category labels in XML" do
        builder.categories(%w[Jan Feb Mar])
        builder.series("Test", data: [1, 2, 3])

        xml = builder.build_xml
        expect(xml).to include("Jan")
        expect(xml).to include("Feb")
        expect(xml).to include("Mar")
      end

      it "includes data values in XML" do
        builder.categories(["A"])
        builder.series("Test", data: [42])

        xml = builder.build_xml
        expect(xml).to include("42")
      end

      it "includes axes for non-pie charts" do
        builder.categories(["A"])
        builder.series("Test", data: [1])

        xml = builder.build_xml
        expect(xml).to include("catAx")
        expect(xml).to include("valAx")
      end

      it "omits axes for pie charts" do
        cb = Uniword::Builder::ChartBuilder.new(chart_type: :pie)
        cb.categories(["A"])
        cb.series("Test", data: [1])

        xml = cb.build_xml
        expect(xml).not_to include("catAx")
        expect(xml).not_to include("valAx")
      end

      it "includes legend by default" do
        builder.categories(["A"])
        builder.series("Test", data: [1])

        xml = builder.build_xml
        expect(xml).to include("legend")
      end

      it "omits legend when configured" do
        builder.legend(show: false)
        builder.categories(["A"])
        builder.series("Test", data: [1])

        xml = builder.build_xml
        expect(xml).not_to include("legend")
      end

      it "handles multiple series" do
        builder.categories(%w[Q1 Q2])
        builder.series("Series 1", data: [10, 20])
        builder.series("Series 2", data: [30, 40])

        xml = builder.build_xml
        expect(xml.scan("Series 1").size).to be >= 1
        expect(xml.scan("Series 2").size).to be >= 1
      end
    end

    describe "build_drawing" do
      it "creates a Drawing element with chart reference" do
        doc = Uniword::Builder::DocumentBuilder.new
        builder.categories(["A"])
        builder.series("Test", data: [1])

        drawing = builder.build_drawing(doc)
        expect(drawing).to be_a(Uniword::Wordprocessingml::Drawing)
        expect(drawing.inline).not_to be_nil
      end

      it "registers chart parts on the document" do
        doc = Uniword::Builder::DocumentBuilder.new
        builder.categories(["A"])
        builder.series("Test", data: [1])

        builder.build_drawing(doc)
        expect(doc.model.chart_parts).not_to be_nil
        expect(doc.model.chart_parts.size).to eq(1)
      end

      it "assigns unique relationship IDs" do
        doc = Uniword::Builder::DocumentBuilder.new
        builder.categories(["A"])
        builder.series("Test", data: [1])
        builder.build_drawing(doc)

        r_id = doc.model.chart_parts.keys.first
        expect(r_id).to start_with("rIdChart")
      end
    end

    describe "DocumentBuilder integration" do
      it "creates a bar chart via DocumentBuilder" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.chart(type: :bar) do |c|
          c.title("Sales")
          c.categories(%w[Q1 Q2 Q3])
          c.series("Revenue", data: [100, 200, 150])
        end

        last_para = doc.model.body.paragraphs.last
        expect(last_para.runs).not_to be_empty
        expect(last_para.runs.first.drawings).not_to be_empty
      end

      it "creates a line chart via DocumentBuilder" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.chart(type: :line) do |c|
          c.title("Trend")
          c.categories(%w[Jan Feb])
          c.series("Value", data: [10, 20])
        end

        expect(doc.model.chart_parts).not_to be_nil
      end

      it "creates a pie chart via DocumentBuilder" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.chart(type: :pie) do |c|
          c.title("Distribution")
          c.categories(%w[A B C])
          c.series("Share", data: [40, 35, 25])
        end

        expect(doc.model.chart_parts).not_to be_nil
      end

      it "registers chart parts with correct target" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.chart do |c|
          c.categories(["X"])
          c.series("Y", data: [1])
        end

        chart_part = doc.model.chart_parts.values.first
        expect(chart_part[:target]).to start_with("charts/")
        expect(chart_part[:target]).to end_with(".xml")
      end

      it "saves DOCX with chart parts" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.chart do |c|
          c.title("Test Chart")
          c.categories(%w[Q1 Q2])
          c.series("Revenue", data: [100, 200])
        end

        path = "/tmp/test_chart.docx"
        doc.save(path)

        expect(File.exist?(path)).to be(true)

        require "zip"
        Zip::File.open(path) do |zip|
          chart_entries = zip.glob("word/charts/*")
          expect(chart_entries.size).to be >= 1

          chart_xml = zip.read(chart_entries.first.name)
          expect(chart_xml).to include("Test Chart")
          expect(chart_xml).to include("barChart")
        end

        safe_rm_f(path)
      end

      it "includes chart relationship in document rels" do
        doc = Uniword::Builder::DocumentBuilder.new
        doc.chart do |c|
          c.categories(["X"])
          c.series("Y", data: [1])
        end

        path = "/tmp/test_chart_rels.docx"
        doc.save(path)

        require "zip"
        Zip::File.open(path) do |zip|
          rels = zip.read("word/_rels/document.xml.rels")
          expect(rels).to include("chart")
        end

        safe_rm_f(path)
      end
    end
  end

  # =========================================================================
  # 16 Combined Scenarios
  # =========================================================================

  describe "combined scenarios" do
    it "creates a document with bibliography and chart" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Research Report")

      doc.heading("Introduction", level: 1)
      doc.paragraph { |p| p << "This is our research." }

      doc.bibliography(style: "APA") do |bib|
        bib.book(
          tag: "Smith2024", author: ["John Smith"],
          title: "Research Methods", year: "2024",
          publisher: "Academic Press"
        )
        bib.journal(
          tag: "Doe2023", author: ["Jane Doe"],
          title: "Key Findings", year: "2023",
          journal: "Science", volume: "100", pages: "1-10"
        )
      end

      doc.chart(type: :bar) do |c|
        c.title("Results")
        c.categories(["Experiment 1", "Experiment 2"])
        c.series("Results", data: [85, 92])
      end

      doc.bibliography_placeholder

      expect(doc.model.bibliography_sources.source.size).to eq(2)
      expect(doc.model.chart_parts).not_to be_nil
    end

    it "creates a complete academic document" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Academic Paper")
      doc.author("Jane Doe")

      # TOC
      doc.toc

      # Sections
      doc.heading("Abstract", level: 1)
      doc.paragraph { |p| p << "This paper presents..." }

      doc.page_break

      doc.heading("Introduction", level: 1)
      doc.paragraph { |p| p << "Background and motivation." }

      doc.heading("Results", level: 1)

      # Chart
      doc.chart(type: :bar) do |c|
        c.title("Experimental Results")
        c.categories(["Control", "Treatment A", "Treatment B"])
        c.series("Score", data: [72, 85, 91])
      end

      doc.page_break

      # Bibliography
      doc.heading("References", level: 1)
      doc.bibliography(style: "APA") do |bib|
        bib.journal(
          tag: "Doe2024", author: ["Jane Doe", "John Smith"],
          title: "Experimental Analysis",
          year: "2024", journal: "Nature",
          volume: "200", pages: "100-115"
        )
        bib.book(
          tag: "Smith2023", author: ["John Smith"],
          title: "Statistics 101", year: "2023",
          publisher: "Textbook Co"
        )
      end
      doc.bibliography_placeholder

      expect(doc.model.bibliography_sources.source.size).to eq(2)
      expect(doc.model.chart_parts).not_to be_nil
      expect(doc.model.body.paragraphs.size).to be > 5
    end

    it "saves a complete document with all features" do
      doc = Uniword::Builder::DocumentBuilder.new
      doc.title("Complete Document")

      doc.heading("Section 1", level: 1)
      doc.paragraph { |p| p << "Content with an image:" }
      doc.image("spec/fixtures/sample.png")

      doc.heading("Data", level: 1)
      doc.chart(type: :bar) do |c|
        c.title("Data Overview")
        c.categories(%w[A B C])
        c.series("Values", data: [10, 20, 30])
      end

      doc.heading("References", level: 1)
      doc.bibliography do |bib|
        bib.book(
          tag: "Ref1", author: ["Author"], title: "Reference",
          year: "2024", publisher: "Pub"
        )
      end
      doc.bibliography_placeholder

      path = "/tmp/test_complete_image_embedding.docx"
      doc.save(path)

      expect(File.exist?(path)).to be(true)

      require "zip"
      Zip::File.open(path) do |zip|
        # Check image
        media_entries = zip.glob("word/media/*")
        expect(media_entries.size).to be >= 1

        # Check chart
        chart_entries = zip.glob("word/charts/*")
        expect(chart_entries.size).to be >= 1

        # Check bibliography
        expect(zip.find_entry("word/sources.xml")).not_to be_nil

        # Check content types
        ct = zip.read("[Content_Types].xml")
        expect(ct).to include("image/png")
        expect(ct).to include("bibliography")
        expect(ct).to include("drawingml.chart")
      end

      safe_rm_f(path)
    end
  end
end
