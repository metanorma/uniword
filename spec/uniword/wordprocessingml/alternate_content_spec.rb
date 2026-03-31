# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Uniword::Wordprocessingml::AlternateContent do
  describe 'serialization' do
    it 'serializes with Choice only' do
      ac = described_class.new
      ac.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<wps:wsp>test</wps:wsp>'
      )

      xml = ac.to_xml
      # Accept both prefixed (mc:) and unprefixed with namespace declaration
      expect(xml).to match(/(<mc:AlternateContent|<AlternateContent[^>]*xmlns=)/)
      expect(xml).to include('http://schemas.openxmlformats.org/markup-compatibility/2006')
      expect(xml).to match(/(<mc:Choice|<Choice)/)
      expect(xml).to match(/(mc:Requires=|Requires=).*wps/)
    end

    it 'serializes with Choice and Fallback' do
      ac = described_class.new
      ac.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<wps:wsp>modern</wps:wsp>'
      )
      ac.fallback = Uniword::Wordprocessingml::Fallback.new(
        content: '<v:shape>legacy</v:shape>'
      )

      xml = ac.to_xml
      expect(xml).to match(/(<mc:AlternateContent|<AlternateContent[^>]*xmlns=)/)
      expect(xml).to include('http://schemas.openxmlformats.org/markup-compatibility/2006')
      expect(xml).to match(/(<mc:Choice|<Choice)/)
      expect(xml).to match(/(<mc:Fallback|<Fallback)/)
    end

    it 'does not serialize Fallback when nil' do
      ac = described_class.new
      ac.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<wps:wsp>test</wps:wsp>'
      )

      xml = ac.to_xml
      expect(xml).to match(/(<mc:AlternateContent|<AlternateContent[^>]*xmlns=)/)
      expect(xml).to match(/(<mc:Choice|<Choice)/)
      expect(xml).not_to include('Fallback')
    end
  end

  describe 'deserialization' do
    it 'parses from XML with Choice only' do
      xml = <<~XML
        <mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
          <mc:Choice mc:Requires="wps">
            <wps:wsp>test</wps:wsp>
          </mc:Choice>
        </mc:AlternateContent>
      XML

      ac = described_class.from_xml(xml)
      expect(ac.choice).to be_a(Uniword::Wordprocessingml::Choice)
      expect(ac.choice.requires).to eq('wps')
      expect(ac.fallback).to be_nil
    end

    it 'parses from XML with Choice and Fallback' do
      xml = <<~XML
        <mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
          <mc:Choice mc:Requires="wps">
            <wps:wsp>modern</wps:wsp>
          </mc:Choice>
          <mc:Fallback>
            <v:shape>legacy</v:shape>
          </mc:Fallback>
        </mc:AlternateContent>
      XML

      ac = described_class.from_xml(xml)
      expect(ac.choice).to be_a(Uniword::Wordprocessingml::Choice)
      expect(ac.choice.requires).to eq('wps')
      expect(ac.fallback).to be_a(Uniword::Wordprocessingml::Fallback)
    end

    it 'handles different namespace requirements' do
      xml = <<~XML
        <mc:AlternateContent xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
          <mc:Choice mc:Requires="w14">
            <w14:docId>content</w14:docId>
          </mc:Choice>
        </mc:AlternateContent>
      XML

      ac = described_class.from_xml(xml)
      expect(ac.choice.requires).to eq('w14')
    end
  end

  describe 'round-trip' do
    it 'preserves structure through serialization with Choice only' do
      original = described_class.new
      original.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<wps:wsp>content</wps:wsp>'
      )

      xml = original.to_xml
      parsed = described_class.from_xml(xml)

      expect(parsed.choice).to be_a(Uniword::Wordprocessingml::Choice)
      expect(parsed.choice.requires).to eq('wps')
      expect(parsed.fallback).to be_nil
    end

    it 'preserves structure through serialization with Choice and Fallback' do
      original = described_class.new
      original.choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: '<wps:wsp>modern</wps:wsp>'
      )
      original.fallback = Uniword::Wordprocessingml::Fallback.new(
        content: '<v:shape>legacy</v:shape>'
      )

      xml = original.to_xml
      parsed = described_class.from_xml(xml)

      expect(parsed.choice).to be_a(Uniword::Wordprocessingml::Choice)
      expect(parsed.choice.requires).to eq('wps')
      expect(parsed.fallback).to be_a(Uniword::Wordprocessingml::Fallback)
    end
  end

  describe 'Choice class' do
    it 'serializes with Requires attribute' do
      choice = Uniword::Wordprocessingml::Choice.new(
        requires: 'wps',
        content: 'test'
      )

      xml = choice.to_xml
      # Accept both prefixed and unprefixed formats
      expect(xml).to match(/(<mc:Choice|<Choice)/)
      expect(xml).to match(/(mc:Requires=|Requires=)/)
    end

    it 'parses from XML' do
      xml = <<~XML
        <mc:Choice xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Requires="wps">
          <wps:wsp>content</wps:wsp>
        </mc:Choice>
      XML

      choice = Uniword::Wordprocessingml::Choice.from_xml(xml)
      expect(choice.requires).to eq('wps')
    end
  end

  describe 'Fallback class' do
    it 'serializes content' do
      fallback = Uniword::Wordprocessingml::Fallback.new(
        content: '<v:shape>test</v:shape>'
      )

      xml = fallback.to_xml
      expect(xml).to include('<Fallback')
      expect(xml).to include('xmlns="http://schemas.openxmlformats.org/markup-compatibility/2006"')
    end

    it 'parses from XML' do
      xml = <<~XML
        <mc:Fallback xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
          <v:shape>content</v:shape>
        </mc:Fallback>
      XML

      fallback = Uniword::Wordprocessingml::Fallback.from_xml(xml)
      expect(fallback).to be_a(Uniword::Wordprocessingml::Fallback)
    end
  end
end
