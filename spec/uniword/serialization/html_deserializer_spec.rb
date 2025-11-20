# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Serialization::HtmlDeserializer do
  let(:deserializer) { described_class.new }

  describe '#deserialize' do
    context 'with invalid input' do
      it 'raises error when parts is nil' do
        expect { deserializer.deserialize(nil) }.to raise_error(ArgumentError, /Parts cannot be nil/)
      end

      it 'raises error when parts is not a hash' do
        expect { deserializer.deserialize('not a hash') }.to raise_error(ArgumentError, /Parts must be a Hash/)
      end
    end

    context 'with empty HTML' do
      it 'returns empty document' do
        parts = { 'html' => '<html><body></body></html>' }
        document = deserializer.deserialize(parts)

        expect(document).to be_a(Uniword::Document)
        expect(document.paragraphs).to be_empty
      end
    end

    context 'with simple paragraph' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p>Simple paragraph text</p>
            </body>
          </html>
        HTML
      end

      it 'parses paragraph correctly' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        expect(document.paragraphs.count).to eq(1)
        expect(document.paragraphs.first.text).to eq('Simple paragraph text')
      end
    end

    context 'with formatted text' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p><b>Bold</b> and <i>italic</i> and <u>underlined</u></p>
            </body>
          </html>
        HTML
      end

      it 'parses inline formatting' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        paragraph = document.paragraphs.first
        expect(paragraph.runs.count).to eq(5)
        expect(paragraph.runs[0].bold?).to be true
        expect(paragraph.runs[2].italic?).to be true
        expect(paragraph.runs[4].underline?).to be true
      end
    end

    context 'with span styling' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p><span style="font-weight:bold;font-size:14pt;color:#FF0000">Styled text</span></p>
            </body>
          </html>
        HTML
      end

      it 'parses inline styles' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        run = document.paragraphs.first.runs.first
        expect(run.bold?).to be true
        expect(run.properties.size).to eq(28)
        expect(run.properties.color).to eq('FF0000')
      end
    end

    context 'with heading elements' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <h1>Heading 1</h1>
              <h2>Heading 2</h2>
              <h3>Heading 3</h3>
            </body>
          </html>
        HTML
      end

      it 'parses headings with correct styles' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        expect(document.paragraphs.count).to eq(3)
        # style method returns style name, style_id returns ID
        expect(document.paragraphs[0].style_id).to eq('Heading1')
        expect(document.paragraphs[1].style_id).to eq('Heading2')
        expect(document.paragraphs[2].style_id).to eq('Heading3')
      end
    end

    context 'with MSO class names' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p class="MsoNormal">Normal paragraph</p>
              <p class="MsoHeading1">Heading paragraph</p>
              <p class="MsoTitle">Title paragraph</p>
            </body>
          </html>
        HTML
      end

      it 'maps MSO classes to styles' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        # style_id returns the ID, not the name
        expect(document.paragraphs[0].style_id).to eq('Normal')
        expect(document.paragraphs[1].style_id).to eq('Heading1')
        expect(document.paragraphs[2].style_id).to eq('Title')
      end
    end

    context 'with paragraph alignment' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p style="text-align:center">Centered</p>
              <p style="text-align:right">Right aligned</p>
              <p style="text-align:justify">Justified</p>
            </body>
          </html>
        HTML
      end

      it 'parses text alignment' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        expect(document.paragraphs[0].alignment).to eq('center')
        expect(document.paragraphs[1].alignment).to eq('right')
        expect(document.paragraphs[2].alignment).to eq('both')
      end
    end

    context 'with paragraph spacing' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p style="margin-top:12pt;margin-bottom:12pt">Spaced paragraph</p>
            </body>
          </html>
        HTML
      end

      it 'parses spacing measurements' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        paragraph = document.paragraphs.first
        expect(paragraph.properties.spacing_before).to eq(240)
        expect(paragraph.properties.spacing_after).to eq(240)
      end
    end

    context 'with paragraph indentation' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p style="margin-left:36pt;text-indent:18pt">Indented paragraph</p>
            </body>
          </html>
        HTML
      end

      it 'parses indentation' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        paragraph = document.paragraphs.first
        expect(paragraph.properties.indent_left).to eq(720)
        expect(paragraph.properties.indent_first_line).to eq(360)
      end
    end

    context 'with table' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <table>
                <tr>
                  <td>Cell 1</td>
                  <td>Cell 2</td>
                </tr>
                <tr>
                  <td>Cell 3</td>
                  <td>Cell 4</td>
                </tr>
              </table>
            </body>
          </html>
        HTML
      end

      # TODO: Fix Lutaml::Model class resolution issue with TableCell
      # The cells array contains symbols instead of TableCell objects
      # This is a known limitation that needs to be addressed
      xit 'parses table structure' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        expect(document.tables.count).to eq(1)
        table = document.tables.first
        expect(table.row_count).to eq(2)
        expect(table.rows[0].cell_count).to eq(2)
        expect(table.rows[0].cells[0].paragraphs.first.text).to eq('Cell 1')
      end
    end

    context 'with mixed content' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <h1>Title</h1>
              <p>First paragraph</p>
              <p>Second paragraph</p>
              <table>
                <tr><td>Table cell</td></tr>
              </table>
              <p>Third paragraph</p>
            </body>
          </html>
        HTML
      end

      # TODO: Same TableCell issue affects this test
      xit 'parses mixed elements in order' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        expect(document.paragraphs.count).to eq(4)
        expect(document.tables.count).to eq(1)
        expect(document.paragraphs[0].text).to eq('Title')
        expect(document.paragraphs[1].text).to eq('First paragraph')
      end
    end

    context 'with line breaks' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p>Line 1<br/>Line 2</p>
            </body>
          </html>
        HTML
      end

      it 'handles br elements' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        paragraph = document.paragraphs.first
        expect(paragraph.runs.count).to eq(3)
        expect(paragraph.runs[1].text).to eq("\n")
      end
    end

    context 'with empty paragraphs' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p></p>
              <p>   </p>
              <p>Real content</p>
            </body>
          </html>
        HTML
      end

      it 'preserves all paragraphs including empty ones' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        # Empty paragraphs are preserved for round-trip fidelity
        expect(document.paragraphs.count).to eq(3)
        expect(document.paragraphs[2].text).to eq('Real content')
      end
    end

    context 'with nested inline elements' do
      let(:html) do
        <<~HTML
          <html>
            <body>
              <p><span style="font-family:Arial"><b>Bold in Arial</b></span></p>
            </body>
          </html>
        HTML
      end

      it 'handles nested formatting' do
        parts = { 'html' => html }
        document = deserializer.deserialize(parts)

        run = document.paragraphs.first.runs.first
        expect(run.text).to eq('Bold in Arial')
        expect(run.bold?).to be true
      end
    end

    context 'measurement conversion' do
      let(:html_pt) { '<html><body><p style="margin-left:12pt">Text</p></body></html>' }
      let(:html_px) { '<html><body><p style="margin-left:16px">Text</p></body></html>' }
      let(:html_cm) { '<html><body><p style="margin-left:2.54cm">Text</p></body></html>' }

      it 'converts pt to twips' do
        parts = { 'html' => html_pt }
        document = deserializer.deserialize(parts)
        expect(document.paragraphs.first.properties.indent_left).to eq(240)
      end

      it 'converts px to twips' do
        parts = { 'html' => html_px }
        document = deserializer.deserialize(parts)
        expect(document.paragraphs.first.properties.indent_left).to eq(240)
      end

      it 'converts cm to twips' do
        parts = { 'html' => html_cm }
        document = deserializer.deserialize(parts)
        expect(document.paragraphs.first.properties.indent_left).to eq(1440)
      end
    end
  end
end
