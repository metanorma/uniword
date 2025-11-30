# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Uniword::Accessibility::AccessibilityReport do
  let(:profile_name) { 'WCAG 2.1' }
  let(:profile_level) { 'Level AA' }

  subject(:report) do
    described_class.new(
      profile_name: profile_name,
      profile_level: profile_level
    )
  end

  let(:error_violation) do
    Uniword::Accessibility::AccessibilityViolation.new(
      rule_id: :image_alt_text,
      wcag_criterion: '1.1.1 Non-text Content',
      level: 'A',
      message: 'Image 1 missing alternative text',
      element: double('Image'),
      severity: :error,
      suggestion: 'Add descriptive alt text'
    )
  end

  let(:warning_violation) do
    Uniword::Accessibility::AccessibilityViolation.new(
      rule_id: :heading_structure,
      wcag_criterion: '1.3.1 Info and Relationships',
      level: 'A',
      message: 'Heading hierarchy skip',
      element: double('Paragraph'),
      severity: :warning,
      suggestion: 'Use sequential heading levels'
    )
  end

  let(:info_violation) do
    Uniword::Accessibility::AccessibilityViolation.new(
      rule_id: :descriptive_headings,
      wcag_criterion: '2.4.6 Headings and Labels',
      level: 'AA',
      message: 'Heading could be more descriptive',
      element: double('Paragraph'),
      severity: :info,
      suggestion: 'Make headings more descriptive'
    )
  end

  describe '#initialize' do
    it 'sets profile name' do
      expect(report.profile_name).to eq('WCAG 2.1')
    end

    it 'sets profile level' do
      expect(report.profile_level).to eq('Level AA')
    end

    it 'initializes empty violations array' do
      expect(report.violations).to eq([])
    end
  end

  describe '#add_violation' do
    it 'adds violation to violations array' do
      report.add_violation(error_violation)
      expect(report.violations).to include(error_violation)
    end

    it 'can add multiple violations' do
      report.add_violation(error_violation)
      report.add_violation(warning_violation)
      expect(report.violations.count).to eq(2)
    end
  end

  describe '#compliant?' do
    context 'when no violations' do
      it 'returns true' do
        expect(report.compliant?).to be true
      end
    end

    context 'when only warnings and info violations' do
      before do
        report.add_violation(warning_violation)
        report.add_violation(info_violation)
      end

      it 'returns true' do
        expect(report.compliant?).to be true
      end
    end

    context 'when error violations exist' do
      before do
        report.add_violation(error_violation)
      end

      it 'returns false' do
        expect(report.compliant?).to be false
      end
    end
  end

  describe '#errors' do
    before do
      report.add_violation(error_violation)
      report.add_violation(warning_violation)
      report.add_violation(info_violation)
    end

    it 'returns only error violations' do
      expect(report.errors).to contain_exactly(error_violation)
    end

    it 'returns correct count' do
      expect(report.errors.count).to eq(1)
    end
  end

  describe '#warnings' do
    before do
      report.add_violation(error_violation)
      report.add_violation(warning_violation)
      report.add_violation(info_violation)
    end

    it 'returns only warning violations' do
      expect(report.warnings).to contain_exactly(warning_violation)
    end

    it 'returns correct count' do
      expect(report.warnings.count).to eq(1)
    end
  end

  describe '#infos' do
    before do
      report.add_violation(error_violation)
      report.add_violation(warning_violation)
      report.add_violation(info_violation)
    end

    it 'returns only info violations' do
      expect(report.infos).to contain_exactly(info_violation)
    end

    it 'returns correct count' do
      expect(report.infos.count).to eq(1)
    end
  end

  describe '#summary' do
    context 'when compliant' do
      it 'returns success message' do
        expect(report.summary).to eq('✅ Document is accessible (WCAG 2.1 Level AA)')
      end
    end

    context 'when not compliant' do
      before do
        report.add_violation(error_violation)
        report.add_violation(warning_violation)
        report.add_violation(info_violation)
      end

      it 'includes profile information' do
        expect(report.summary).to include('WCAG 2.1 Level AA')
      end

      it 'includes counts by severity' do
        summary = report.summary
        expect(summary).to include('Errors: 1')
        expect(summary).to include('Warnings: 1')
        expect(summary).to include('Info: 1')
      end

      it 'groups violations by rule' do
        expect(report.summary).to include('image_alt_text')
        expect(report.summary).to include('heading_structure')
      end

      it 'includes violation messages' do
        expect(report.summary).to include('Image 1 missing alternative text')
      end
    end

    context 'when more than 3 violations per rule' do
      before do
        5.times do |i|
          report.add_violation(
            Uniword::Accessibility::AccessibilityViolation.new(
              rule_id: :image_alt_text,
              wcag_criterion: '1.1.1',
              level: 'A',
              message: "Image #{i + 1} issue",
              element: double('Image'),
              severity: :error,
              suggestion: 'Fix it'
            )
          )
        end
      end

      it 'shows first 3 and mentions more' do
        summary = report.summary
        expect(summary).to include('... and 2 more')
      end
    end
  end

  describe '#to_json' do
    before do
      report.add_violation(error_violation)
      report.add_violation(warning_violation)
    end

    it 'returns valid JSON' do
      expect { JSON.parse(report.to_json) }.not_to raise_error
    end

    it 'includes profile information' do
      json = JSON.parse(report.to_json)
      expect(json['profile']['name']).to eq('WCAG 2.1')
      expect(json['profile']['level']).to eq('Level AA')
    end

    it 'includes compliance status' do
      json = JSON.parse(report.to_json)
      expect(json['compliant']).to be false
    end

    it 'includes summary counts' do
      json = JSON.parse(report.to_json)
      expect(json['summary']['total']).to eq(2)
      expect(json['summary']['errors']).to eq(1)
      expect(json['summary']['warnings']).to eq(1)
    end

    it 'includes violations array' do
      json = JSON.parse(report.to_json)
      expect(json['violations']).to be_an(Array)
      expect(json['violations'].count).to eq(2)
    end

    it 'includes violation details' do
      json = JSON.parse(report.to_json)
      violation = json['violations'].first
      expect(violation['rule_id']).to eq('image_alt_text')
      expect(violation['wcag_criterion']).to eq('1.1.1 Non-text Content')
      expect(violation['message']).to eq('Image 1 missing alternative text')
    end
  end

  describe '#export_html' do
    let(:temp_file) { Tempfile.new(['accessibility_report', '.html']) }

    after do
      temp_file.close
      temp_file.unlink
    end

    before do
      report.add_violation(error_violation)
      report.add_violation(warning_violation)
    end

    it 'creates HTML file' do
      report.export_html(temp_file.path)
      expect(File.exist?(temp_file.path)).to be true
    end

    it 'generates valid HTML' do
      report.export_html(temp_file.path)
      html = File.read(temp_file.path)
      expect(html).to include('<!DOCTYPE html>')
      expect(html).to include('</html>')
    end

    it 'includes profile information' do
      report.export_html(temp_file.path)
      html = File.read(temp_file.path)
      expect(html).to include('WCAG 2.1')
      expect(html).to include('Level AA')
    end

    it 'includes violation details' do
      report.export_html(temp_file.path)
      html = File.read(temp_file.path)
      expect(html).to include('Image 1 missing alternative text')
      expect(html).to include('Add descriptive alt text')
    end

    it 'includes CSS styling' do
      report.export_html(temp_file.path)
      html = File.read(temp_file.path)
      expect(html).to include('<style>')
      expect(html).to include('.error')
      expect(html).to include('.warning')
    end

    it 'shows compliance status' do
      report.export_html(temp_file.path)
      html = File.read(temp_file.path)
      expect(html).to include('Not Compliant')
    end

    context 'when compliant' do
      let(:compliant_report) do
        described_class.new(
          profile_name: 'WCAG 2.1',
          profile_level: 'Level AA'
        )
      end

      it 'shows compliant status' do
        compliant_report.export_html(temp_file.path)
        html = File.read(temp_file.path)
        expect(html).to include('Compliant')
      end
    end
  end
end
