# frozen_string_literal: true

require "spec_helper"
require "canon/rspec_matchers"

VT = Uniword::Ooxml::Types::VariantTypes

RSpec.describe "Shared OOXML Schemas Round-Trip" do
  # =========================================================================
  # 1. Variant Types (vt: namespace)
  # =========================================================================
  describe Uniword::Ooxml::Types::VariantTypes::VtLpwstr do
    it "round-trips lpwstr value" do
      obj = described_class.new(value: "Hello World")
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.value).to eq("Hello World")
    end
  end

  describe Uniword::Ooxml::Types::VariantTypes::VtI4 do
    it "round-trips i4 integer value" do
      obj = described_class.new(value: "42")
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.value).to eq("42")
    end
  end

  describe Uniword::Ooxml::Types::VariantTypes::VtBool do
    it "round-trips bool value" do
      obj = described_class.new(value: "1")
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.value).to eq("1")
    end
  end

  describe Uniword::Ooxml::Types::VariantTypes::VtVariant do
    it "round-trips variant with lpwstr child" do
      obj = described_class.new(lpwstr: VT::VtLpwstr.new(value: "Title"))
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.text_value).to eq("Title")
    end

    it "round-trips variant with i4 child" do
      obj = described_class.new(i4: VT::VtI4.new(value: "1"))
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.text_value).to eq("1")
    end
  end

  describe Uniword::Ooxml::Types::VariantTypes::VtVector do
    it "round-trips vector of lpstr values" do
      obj = described_class.new(
        base_type: "lpstr",
        size: "2",
        lpstr_values: [
          VT::VtLpstr.new(value: "Title"),
          VT::VtLpstr.new(value: "")
        ]
      )
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.base_type).to eq("lpstr")
      expect(restored.size).to eq("2")
      expect(restored.values).to eq(["Title", ""])
    end

    it "round-trips vector of variant values" do
      obj = described_class.new(
        base_type: "variant",
        size: "2",
        variant_values: [
          VT::VtVariant.new(lpstr: VT::VtLpstr.new(value: "Title")),
          VT::VtVariant.new(i4: VT::VtI4.new(value: "1"))
        ]
      )
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.base_type).to eq("variant")
      expect(restored.variant_values.size).to eq(2)
      expect(restored.variant_values[0].text_value).to eq("Title")
      expect(restored.variant_values[1].text_value).to eq("1")
    end

    it "round-trips vector of i4 values" do
      obj = described_class.new(
        base_type: "i4",
        size: "3",
        i4_values: [
          VT::VtI4.new(value: "10"),
          VT::VtI4.new(value: "20"),
          VT::VtI4.new(value: "30")
        ]
      )
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.values).to eq(%w[10 20 30])
    end
  end

  describe Uniword::Ooxml::Types::VariantTypes::VtArray do
    it "round-trips array with bounds" do
      obj = described_class.new(
        base_type: "lpwstr",
        size: "2",
        l_bound: "0",
        u_bound: "1"
      )
      xml = obj.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.base_type).to eq("lpwstr")
      expect(restored.size).to eq("2")
      expect(restored.l_bound).to eq("0")
      expect(restored.u_bound).to eq("1")
    end
  end

  # =========================================================================
  # 2. Custom Properties (docProps/custom.xml)
  # =========================================================================
  describe Uniword::Ooxml::CustomProperties do
    let(:apa_custom_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
                    xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
          <property fmtid="{D5CDD505-2E9C-101B-9397-08002B2CF9AE}" pid="2" name="AssetID">
            <vt:lpwstr>TF10002067</vt:lpwstr>
          </property>
        </Properties>
      XML
    end

    let(:cover_toc_custom_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/custom-properties"
                    xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
          <property fmtid="{D5CDD505-2E9C-101B-9397-08002B2CF9AE}" pid="2"
                    name="_dlc_DocIdItemGuid">
            <vt:lpwstr>40c25c02-a5e0-48a4-913c-93e0d5121f72</vt:lpwstr>
          </property>
          <property fmtid="{D5CDD505-2E9C-101B-9397-08002B2CF9AE}" pid="3"
                    name="ContentTypeId">
            <vt:lpwstr>0x010100012E2E405031D74DB051ADDB3D34E572</vt:lpwstr>
          </property>
          <property fmtid="{D5CDD505-2E9C-101B-9397-08002B2CF9AE}" pid="4" name="AssetID">
            <vt:lpwstr>TF10002005</vt:lpwstr>
          </property>
        </Properties>
      XML
    end

    it "parses APA fixture custom properties" do
      props = described_class.from_xml(apa_custom_xml)
      expect(props.properties.size).to eq(1)
      prop = props.properties.first
      expect(prop.name).to eq("AssetID")
      expect(prop.fmtid).to eq("{D5CDD505-2E9C-101B-9397-08002B2CF9AE}")
      expect(prop.pid).to eq(2)
      expect(prop.value).to eq("TF10002067")
    end

    it "parses cover-toc fixture with multiple properties" do
      props = described_class.from_xml(cover_toc_custom_xml)
      expect(props.properties.size).to eq(3)
      expect(props.properties[0].name).to eq("_dlc_DocIdItemGuid")
      expect(props.properties[0].value).to eq("40c25c02-a5e0-48a4-913c-93e0d5121f72")
      expect(props.properties[1].name).to eq("ContentTypeId")
      expect(props.properties[2].name).to eq("AssetID")
      expect(props.properties[2].value).to eq("TF10002005")
    end

    it "round-trips APA custom properties through XML" do
      original = described_class.from_xml(apa_custom_xml)
      xml = original.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.properties.size).to eq(1)
      expect(restored.properties.first.name).to eq("AssetID")
      expect(restored.properties.first.value).to eq("TF10002067")
    end

    it "round-trips cover-toc custom properties through XML" do
      original = described_class.from_xml(cover_toc_custom_xml)
      xml = original.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.properties.size).to eq(3)
      expect(restored.properties.map(&:name)).to eq(
        %w[_dlc_DocIdItemGuid ContentTypeId AssetID]
      )
      expect(restored.properties.map(&:value)).to eq(
        %w[40c25c02-a5e0-48a4-913c-93e0d5121f72
           0x010100012E2E405031D74DB051ADDB3D34E572
           TF10002005]
      )
    end

    it "creates custom properties programmatically" do
      props = described_class.new
      prop = Uniword::Ooxml::CustomProperty.new(
        fmtid: "{D5CDD505-2E9C-101B-9397-08002B2CF9AE}",
        pid: 2,
        name: "Department",
        lpwstr: VT::VtLpwstr.new(value: "Engineering")
      )
      props.properties << prop

      xml = props.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.properties.size).to eq(1)
      expect(restored.properties.first.name).to eq("Department")
      expect(restored.properties.first.value).to eq("Engineering")
    end

    it "handles bool custom property values" do
      props = described_class.new
      prop = Uniword::Ooxml::CustomProperty.new(
        fmtid: "{D5CDD505-2E9C-101B-9397-08002B2CF9AE}",
        pid: 2,
        name: "IsReviewed",
        bool: VT::VtBool.new(value: "1")
      )
      props.properties << prop

      xml = props.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.properties.first.value).to eq("1")
    end
  end

  # =========================================================================
  # 3. App Properties - Extended Fields (HeadingPairs, TitlesOfParts)
  # =========================================================================
  describe Uniword::Ooxml::AppProperties do
    let(:apa_app_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
                    xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
          <Template>APA Style Paper.dotx</Template>
          <TotalTime>0</TotalTime>
          <Pages>9</Pages>
          <Words>726</Words>
          <Characters>4140</Characters>
          <Application>Microsoft Office Word</Application>
          <DocSecurity>0</DocSecurity>
          <Lines>34</Lines>
          <Paragraphs>9</Paragraphs>
          <ScaleCrop>false</ScaleCrop>
          <HeadingPairs>
            <vt:vector size="2" baseType="variant">
              <vt:variant><vt:lpstr>Title</vt:lpstr></vt:variant>
              <vt:variant><vt:i4>1</vt:i4></vt:variant>
            </vt:vector>
          </HeadingPairs>
          <TitlesOfParts>
            <vt:vector size="1" baseType="lpstr">
              <vt:lpstr></vt:lpstr>
            </vt:vector>
          </TitlesOfParts>
          <Company></Company>
          <LinksUpToDate>false</LinksUpToDate>
          <CharactersWithSpaces>4857</CharactersWithSpaces>
          <SharedDoc>false</SharedDoc>
          <HyperlinksChanged>false</HyperlinksChanged>
          <AppVersion>16.0000</AppVersion>
        </Properties>
      XML
    end

    it "parses all standard app properties from APA fixture" do
      props = described_class.from_xml(apa_app_xml)
      expect(props.total_time).to eq("0")
      expect(props.pages).to eq("9")
      expect(props.words).to eq("726")
      expect(props.characters).to eq("4140")
      expect(props.doc_security).to eq("0")
      expect(props.lines).to eq("34")
      expect(props.paragraphs).to eq("9")
      expect(props.scale_crop).to eq("false")
      expect(props.links_up_to_date).to eq("false")
      expect(props.characters_with_spaces).to eq("4857")
      expect(props.shared_doc).to eq("false")
      expect(props.hyperlinks_changed).to eq("false")
      expect(props.app_version).to eq("16.0000")
    end

    it "parses HeadingPairs vector from real fixture XML" do
      props = described_class.from_xml(apa_app_xml)
      hp = props.heading_pairs
      expect(hp).to be_a(Uniword::Ooxml::HeadingPairs)
      vec = hp.vector
      expect(vec).to be_a(VT::VtVector)
      expect(vec.base_type).to eq("variant")
      expect(vec.variant_values.size).to eq(2)
      expect(vec.variant_values[0].text_value).to eq("Title")
      expect(vec.variant_values[1].text_value).to eq("1")
    end

    it "parses TitlesOfParts vector from real fixture XML" do
      props = described_class.from_xml(apa_app_xml)
      top = props.titles_of_parts
      expect(top).to be_a(Uniword::Ooxml::TitlesOfParts)
      vec = top.vector
      expect(vec).to be_a(VT::VtVector)
      expect(vec.base_type).to eq("lpstr")
      expect(vec.values).to eq([""])
    end

    it "round-trips app properties with HeadingPairs and TitlesOfParts" do
      original = described_class.from_xml(apa_app_xml)
      xml = original.to_xml
      restored = described_class.from_xml(xml)

      expect(restored.template).to eq("APA Style Paper.dotx")
      expect(restored.pages).to eq("9")
      expect(restored.application).to eq("Microsoft Office Word")

      hp = restored.heading_pairs
      expect(hp.vector.base_type).to eq("variant")
      expect(hp.vector.variant_values.size).to eq(2)
      expect(hp.vector.variant_values[0].text_value).to eq("Title")
      expect(hp.vector.variant_values[1].text_value).to eq("1")

      top = restored.titles_of_parts
      expect(top.vector.base_type).to eq("lpstr")
      expect(top.vector.values).to eq([""])
    end
  end

  # =========================================================================
  # 4. Custom XML Data Properties (customXml/itemProps*.xml)
  # =========================================================================
  describe Uniword::Customxml::DataStoreItem do
    let(:item_props_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <ds:datastoreItem ds:itemID="{9B8B2303-F514-4E15-89A3-727D86B05CBD}"
          xmlns:ds="http://schemas.openxmlformats.org/officeDocument/2006/customXml">
          <ds:schemaRefs>
            <ds:schemaRef ds:uri="http://schemas.openxmlformats.org/officeDocument/2006/bibliography"/>
          </ds:schemaRefs>
        </ds:datastoreItem>
      XML
    end

    it "parses datastoreItem with itemID" do
      item = described_class.from_xml(item_props_xml)
      expect(item.item_id).to eq("{9B8B2303-F514-4E15-89A3-727D86B05CBD}")
    end

    it "parses datastoreItem with schemaRef uri" do
      item = described_class.from_xml(item_props_xml)
      expect(item.schema_refs).to be_a(Uniword::Customxml::SchemaRefs)
      expect(item.schema_refs.refs.size).to eq(1)
      expect(item.schema_refs.refs.first.uri).to eq(
        "http://schemas.openxmlformats.org/officeDocument/2006/bibliography"
      )
    end

    it "round-trips datastoreItem through XML" do
      original = described_class.from_xml(item_props_xml)
      xml = original.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.item_id).to eq("{9B8B2303-F514-4E15-89A3-727D86B05CBD}")
      expect(restored.schema_refs.refs.size).to eq(1)
      expect(restored.schema_refs.refs.first.uri).to eq(
        "http://schemas.openxmlformats.org/officeDocument/2006/bibliography"
      )
    end
  end

  # =========================================================================
  # 5. Bibliography Sources (customXml/item*.xml)
  # =========================================================================
  describe Uniword::Bibliography::Sources do
    let(:bib_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <b:Sources SelectedStyle="\\APASixthEditionOfficeOnline.xsl"
                   StyleName="APA" Version="6"
                   xmlns:b="http://schemas.openxmlformats.org/officeDocument/2006/bibliography">
          <b:Source>
            <b:Tag>Article</b:Tag>
            <b:SourceType>JournalArticle</b:SourceType>
            <b:Guid>{A9826F97-9AB6-4323-9880-F46D9FA5FDF4}</b:Guid>
            <b:Title>Article Title</b:Title>
            <b:Year>Year</b:Year>
            <b:JournalName>Journal Title</b:JournalName>
            <b:Pages>Pages From - To</b:Pages>
            <b:Author>
              <b:Author>
                <b:NameList>
                  <b:Person>
                    <b:Last>Last Name</b:Last>
                    <b:First>First,</b:First>
                    <b:Middle>Middle</b:Middle>
                  </b:Person>
                </b:NameList>
              </b:Author>
            </b:Author>
            <b:RefOrder>1</b:RefOrder>
          </b:Source>
        </b:Sources>
      XML
    end

    it "parses bibliography with Version attribute" do
      sources = described_class.from_xml(bib_xml)
      expect(sources.selected_style).to eq('\\APASixthEditionOfficeOnline.xsl')
      expect(sources.style_name).to eq("APA")
      expect(sources.version).to eq("6")
      expect(sources.source.size).to eq(1)
    end

    it "round-trips bibliography sources through XML" do
      original = described_class.from_xml(bib_xml)
      xml = original.to_xml
      restored = described_class.from_xml(xml)

      expect(restored.selected_style).to eq('\\APASixthEditionOfficeOnline.xsl')
      expect(restored.style_name).to eq("APA")
      expect(restored.version).to eq("6")
      expect(restored.source.size).to eq(1)

      src = restored.source.first
      expect(src.tag).to eq("Article")
      expect(src.source_type).to eq("JournalArticle")
      expect(src.title).to eq("Article Title")
    end

    it "parses nested Author structure correctly" do
      sources = described_class.from_xml(bib_xml)
      author = sources.source.first.author
      expect(author).to be_a(Uniword::Bibliography::Author)
      expect(author.author).to be_a(Uniword::Bibliography::Author)
      expect(author.author.name_list).to be_a(Uniword::Bibliography::NameList)
      person = author.author.name_list.person.first
      expect(person.last).to eq("Last Name")
      expect(person.first).to eq("First,")
      expect(person.middle).to eq("Middle")
    end

    it "round-trips bibliography with full author details" do
      original = described_class.from_xml(bib_xml)
      restored = described_class.from_xml(original.to_xml)

      person = restored.source.first.author.author.name_list.person.first
      expect(person.last).to eq("Last Name")
      expect(person.first).to eq("First,")
      expect(person.middle).to eq("Middle")
    end

    it "parses all Source metadata fields" do
      sources = described_class.from_xml(bib_xml)
      src = sources.source.first
      expect(src.journal_name).to eq("Journal Title")
      expect(src.pages).to eq("Pages From - To")
      expect(src.ref_order).to eq("1")
      expect(src.guid).to eq("{A9826F97-9AB6-4323-9880-F46D9FA5FDF4}")
    end
  end

  describe Uniword::Bibliography::Source do
    it "round-trips a Book source with extended fields" do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <b:Sources xmlns:b="http://schemas.openxmlformats.org/officeDocument/2006/bibliography">
          <b:Source>
            <b:Tag>Smith2024</b:Tag>
            <b:SourceType>Book</b:SourceType>
            <b:Guid>{12345678-1234-1234-1234-123456789ABC}</b:Guid>
            <b:Title>The Great Book</b:Title>
            <b:Year>2024</b:Year>
            <b:City>New York</b:City>
            <b:Publisher>Academic Press</b:Publisher>
            <b:Edition>2nd</b:Edition>
            <b:Volume>3</b:Volume>
            <b:Pages>100-200</b:Pages>
            <b:StandardNumber>ISBN 978-0-123456-78-9</b:StandardNumber>
            <b:URL>https://example.com/book</b:URL>
            <b:Comments>Important reference</b:Comments>
            <b:ShortTitle>Great Book</b:ShortTitle>
            <b:Author>
              <b:Editor>
                <b:NameList>
                  <b:Person>
                    <b:Last>Editor</b:Last>
                    <b:First>Jane</b:First>
                  </b:Person>
                </b:NameList>
              </b:Editor>
            </b:Author>
            <b:RefOrder>1</b:RefOrder>
          </b:Source>
        </b:Sources>
      XML

      sources = Uniword::Bibliography::Sources.from_xml(xml)
      src = sources.source.first
      expect(src.source_type).to eq("Book")
      expect(src.title).to eq("The Great Book")
      expect(src.city).to eq("New York")
      expect(src.publisher).to eq("Academic Press")
      expect(src.edition).to eq("2nd")
      expect(src.volume).to eq("3")
      expect(src.standard_number).to eq("ISBN 978-0-123456-78-9")
      expect(src.url).to eq("https://example.com/book")
      expect(src.comments).to eq("Important reference")
      expect(src.short_title).to eq("Great Book")

      # Editor role element (CT_NameType)
      expect(src.author.editor).to be_a(Uniword::Bibliography::NameType)
      expect(src.author.editor.name_list.person.first.last).to eq("Editor")

      # Round-trip
      restored = Uniword::Bibliography::Sources.from_xml(sources.to_xml).source.first
      expect(restored.title).to eq("The Great Book")
      expect(restored.city).to eq("New York")
      expect(restored.standard_number).to eq("ISBN 978-0-123456-78-9")
      expect(restored.author.editor.name_list.person.first.last).to eq("Editor")
    end

    it "handles Performer role with corporate author" do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <b:Sources xmlns:b="http://schemas.openxmlformats.org/officeDocument/2006/bibliography">
          <b:Source>
            <b:Tag>Perf1</b:Tag>
            <b:SourceType>Art</b:SourceType>
            <b:Title>Performance Art</b:Title>
            <b:Author>
              <b:Performer>
                <b:Corporate>Acme Theater Co</b:Corporate>
              </b:Performer>
            </b:Author>
          </b:Source>
        </b:Sources>
      XML

      sources = Uniword::Bibliography::Sources.from_xml(xml)
      src = sources.source.first
      expect(src.author.performer).to be_a(Uniword::Bibliography::Author)
      expect(src.author.performer.corporate).to eq("Acme Theater Co")

      restored = Uniword::Bibliography::Sources.from_xml(sources.to_xml).source.first
      expect(restored.author.performer.corporate).to eq("Acme Theater Co")
    end
  end

  # =========================================================================
  # 6. Schema Library (sl:schemaLibrary)
  # =========================================================================
  describe Uniword::Ooxml::SchemaLibrary do
    it "round-trips schema library with entries" do
      xml = <<~XML
        <sl:schemaLibrary xmlns:sl="http://schemas.openxmlformats.org/schemaLibrary/2006/main">
          <sl:schema sl:uri="http://example.com/schema1"
                     sl:manifestLocation="http://example.com/schema1.xsd"/>
          <sl:schema sl:uri="http://example.com/schema2"
                     sl:manifestLocation="http://example.com/schema2.xsd"/>
        </sl:schemaLibrary>
      XML

      original = described_class.from_xml(xml)
      expect(original.schemas.size).to eq(2)
      expect(original.schemas[0].uri).to eq("http://example.com/schema1")
      expect(original.schemas[1].uri).to eq("http://example.com/schema2")

      restored = described_class.from_xml(original.to_xml)
      expect(restored.schemas.size).to eq(2)
      expect(restored.schemas[0].uri).to eq("http://example.com/schema1")
      expect(restored.schemas[1].uri).to eq("http://example.com/schema2")
    end

    it "handles empty schema library" do
      sl = described_class.new
      expect(sl.schemas).to be_empty

      xml = sl.to_xml
      restored = described_class.from_xml(xml)
      expect(restored.schemas).to be_empty
    end
  end

  # =========================================================================
  # 7. Additional Characteristics
  # =========================================================================
  describe Uniword::Ooxml::AdditionalCharacteristics do
    it "round-trips characteristics" do
      xml = <<~XML
        <ac:additionalCharacteristics xmlns:ac="http://schemas.openxmlformats.org/officeDocument/2006/characteristics">
          <ac:characteristic ac:name="name1" ac:relation="le" ac:val="100"/>
          <ac:characteristic ac:name="name2" ac:relation="eq" ac:val="UTF-8" ac:vocabulary="http://example.com/vocab"/>
        </ac:additionalCharacteristics>
      XML

      original = described_class.from_xml(xml)
      expect(original.characteristics.size).to eq(2)
      expect(original.characteristics[0].name).to eq("name1")
      expect(original.characteristics[0].relation).to eq("le")
      expect(original.characteristics[0].val).to eq("100")
      expect(original.characteristics[1].vocabulary).to eq("http://example.com/vocab")

      restored = described_class.from_xml(original.to_xml)
      expect(restored.characteristics.size).to eq(2)
      expect(restored.characteristics[0].name).to eq("name1")
      expect(restored.characteristics[1].vocabulary).to eq("http://example.com/vocab")
    end

    it "handles empty characteristics" do
      ac = described_class.new
      expect(ac.characteristics).to be_empty
    end
  end

  # =========================================================================
  # 8. Full DOCX Package Round-Trip
  # =========================================================================
  describe "DOCX package round-trip with shared schemas" do
    let(:apa_path) do
      "spec/fixtures/word-template-apa-style-paper/word-template-apa-style-paper.docx"
    end

    let(:cover_toc_path) do
      "spec/fixtures/word-template-paper-with-cover-and-toc/word-template-paper-with-cover-and-toc.docx"
    end

    it "round-trips APA fixture preserving custom properties" do
      package = Uniword::Ooxml::DocxPackage.from_file(apa_path)
      expect(package.custom_properties).to be_a(Uniword::Ooxml::CustomProperties)
      expect(package.custom_properties.properties.size).to eq(1)
      expect(package.custom_properties.properties.first.name).to eq("AssetID")
      expect(package.custom_properties.properties.first.value).to eq("TF10002067")
    end

    it "round-trips APA fixture preserving bibliography in customXml" do
      package = Uniword::Ooxml::DocxPackage.from_file(apa_path)
      expect(package.custom_xml_items).not_to be_empty
      item1 = package.custom_xml_items.find { |i| i[:index] == 1 }
      expect(item1).not_to be_nil
      expect(item1[:xml_content]).to include("b:Sources")
      expect(item1[:xml_content]).to include('Version="6"')
    end

    it "round-trips cover-toc fixture with multiple custom properties" do
      package = Uniword::Ooxml::DocxPackage.from_file(cover_toc_path)
      expect(package.custom_properties).to be_a(Uniword::Ooxml::CustomProperties)
      expect(package.custom_properties.properties.size).to eq(3)
      names = package.custom_properties.properties.map(&:name)
      expect(names).to include("AssetID", "ContentTypeId", "_dlc_DocIdItemGuid")
    end

    it "round-trips cover-toc fixture preserving customXml items" do
      package = Uniword::Ooxml::DocxPackage.from_file(cover_toc_path)
      expect(package.custom_xml_items).not_to be_empty
      expect(package.custom_xml_items.size).to be >= 2
    end

    it "round-trips APA fixture preserving app.xml basic fields" do
      package = Uniword::Ooxml::DocxPackage.from_file(apa_path)
      app = package.app_properties
      expect(app.template).to eq("APA Style Paper.dotx")
      expect(app.pages).to eq("9")
      expect(app.application).to eq("Microsoft Office Word")
    end
  end

  # =========================================================================
  # 9. SchemaLibrary within Settings (word/settings.xml)
  # =========================================================================
  describe "SchemaLibrary in Settings" do
    let(:settings_with_schema_lib) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                    xmlns:sl="http://schemas.openxmlformats.org/schemaLibrary/2006/main">
          <w:zoom w:percent="100"/>
          <w:defaultTabStop w:val="720"/>
          <sl:schemaLibrary>
            <sl:schema sl:uri="http://example.com/schema1"
                       sl:manifestLocation="http://example.com/schema1.xsd"/>
            <sl:schema sl:uri="http://example.com/schema2"/>
          </sl:schemaLibrary>
        </w:settings>
      XML
    end

    it "parses schemaLibrary from settings.xml" do
      settings = Uniword::Wordprocessingml::Settings.from_xml(settings_with_schema_lib)
      expect(settings.schema_library).to be_a(Uniword::Ooxml::SchemaLibrary)
      expect(settings.schema_library.schemas.size).to eq(2)
      expect(settings.schema_library.schemas[0].uri).to eq("http://example.com/schema1")
      expect(settings.schema_library.schemas[0].manifest_location).to eq("http://example.com/schema1.xsd")
      expect(settings.schema_library.schemas[1].uri).to eq("http://example.com/schema2")
    end

    it "round-trips settings.xml with schemaLibrary preserving all data" do
      original = Uniword::Wordprocessingml::Settings.from_xml(settings_with_schema_lib)
      xml = original.to_xml
      restored = Uniword::Wordprocessingml::Settings.from_xml(xml)

      expect(restored.zoom.percent).to eq(100)
      expect(restored.default_tab_stop.val).to eq("720")
      expect(restored.schema_library.schemas.size).to eq(2)
      expect(restored.schema_library.schemas[0].uri).to eq("http://example.com/schema1")
      expect(restored.schema_library.schemas[0].manifest_location).to eq("http://example.com/schema1.xsd")
      expect(restored.schema_library.schemas[1].uri).to eq("http://example.com/schema2")
    end

    it "handles settings without schemaLibrary" do
      xml = <<~XML
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
          <w:zoom w:percent="100"/>
        </w:settings>
      XML
      settings = Uniword::Wordprocessingml::Settings.from_xml(xml)
      expect(settings.schema_library).to be_nil
    end
  end
end
