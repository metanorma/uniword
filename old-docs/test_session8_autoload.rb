#!/usr/bin/env ruby
# frozen_string_literal: true

# Test autoload for Session 8: Word Extended Namespaces

require_relative 'lib/generated/wordprocessingml_2010'
require_relative 'lib/generated/wordprocessingml_2013'
require_relative 'lib/generated/wordprocessingml_2016'

puts '=' * 80
puts 'Testing Session 8 Autoload: Word Extended Namespaces'
puts '=' * 80
puts

# Test Word 2010 (w14:) - 25 classes
puts 'Testing Word 2010 Extended (w14:) - 25 classes...'
w14_classes = [
  Uniword::Generated::Wordprocessingml2010::Checkbox,
  Uniword::Generated::Wordprocessingml2010::CheckedState,
  Uniword::Generated::Wordprocessingml2010::ConditionalFormatStyle,
  Uniword::Generated::Wordprocessingml2010::ConflictDeletion,
  Uniword::Generated::Wordprocessingml2010::ConflictInsertion,
  Uniword::Generated::Wordprocessingml2010::ConflictMode,
  Uniword::Generated::Wordprocessingml2010::CustomXmlConflictInsertion,
  Uniword::Generated::Wordprocessingml2010::DocId,
  Uniword::Generated::Wordprocessingml2010::DocPartGallery,
  Uniword::Generated::Wordprocessingml2010::DocPartObj,
  Uniword::Generated::Wordprocessingml2010::EntityPicker,
  Uniword::Generated::Wordprocessingml2010::Ligatures,
  Uniword::Generated::Wordprocessingml2010::NumberForm,
  Uniword::Generated::Wordprocessingml2010::ParaId,
  Uniword::Generated::Wordprocessingml2010::Props3d,
  Uniword::Generated::Wordprocessingml2010::SdtContent,
  Uniword::Generated::Wordprocessingml2010::SdtProperties,
  Uniword::Generated::Wordprocessingml2010::StructuredDocumentTag,
  Uniword::Generated::Wordprocessingml2010::TextFill,
  Uniword::Generated::Wordprocessingml2010::TextGlow,
  Uniword::Generated::Wordprocessingml2010::TextId,
  Uniword::Generated::Wordprocessingml2010::TextOutline,
  Uniword::Generated::Wordprocessingml2010::TextReflection,
  Uniword::Generated::Wordprocessingml2010::TextShadow,
  Uniword::Generated::Wordprocessingml2010::UncheckedState
]
puts "✅ Loaded #{w14_classes.size}/25 Word 2010 classes"
puts

# Test Word 2013 (w15:) - 20 classes
puts 'Testing Word 2013 Extended (w15:) - 20 classes...'
w15_classes = [
  Uniword::Generated::Wordprocessingml2013::ChartProps,
  Uniword::Generated::Wordprocessingml2013::ChartTrackingRefBased,
  Uniword::Generated::Wordprocessingml2013::CommentAuthor,
  Uniword::Generated::Wordprocessingml2013::CommentCollapsed,
  Uniword::Generated::Wordprocessingml2013::CommentDone,
  Uniword::Generated::Wordprocessingml2013::CommentEx,
  Uniword::Generated::Wordprocessingml2013::CommentsIds,
  Uniword::Generated::Wordprocessingml2013::DocPartAnchor,
  Uniword::Generated::Wordprocessingml2013::DocumentPart,
  Uniword::Generated::Wordprocessingml2013::FootnoteColumns,
  Uniword::Generated::Wordprocessingml2013::PeopleGroup,
  Uniword::Generated::Wordprocessingml2013::Person,
  Uniword::Generated::Wordprocessingml2013::PresenceInfo,
  Uniword::Generated::Wordprocessingml2013::RepeatingSectionItem,
  Uniword::Generated::Wordprocessingml2013::RepeatingSection,
  Uniword::Generated::Wordprocessingml2013::SdtAppearance,
  Uniword::Generated::Wordprocessingml2013::SdtColor,
  Uniword::Generated::Wordprocessingml2013::SdtDataBinding,
  Uniword::Generated::Wordprocessingml2013::WebExtensionLinked,
  Uniword::Generated::Wordprocessingml2013::WebExtension
]
puts "✅ Loaded #{w15_classes.size}/20 Word 2013 classes"
puts

# Test Word 2016 (w16:) - 15 classes
puts 'Testing Word 2016 Extended (w16:) - 15 classes...'
w16_classes = [
  Uniword::Generated::Wordprocessingml2016::CellRsid,
  Uniword::Generated::Wordprocessingml2016::ChartColorStyle,
  Uniword::Generated::Wordprocessingml2016::ChartStyle2016,
  Uniword::Generated::Wordprocessingml2016::CommentsExt,
  Uniword::Generated::Wordprocessingml2016::ConflictMode2016,
  Uniword::Generated::Wordprocessingml2016::ContentId,
  Uniword::Generated::Wordprocessingml2016::DataBinding2016,
  Uniword::Generated::Wordprocessingml2016::ExtensionList,
  Uniword::Generated::Wordprocessingml2016::Extension,
  Uniword::Generated::Wordprocessingml2016::PersistentDocumentId,
  Uniword::Generated::Wordprocessingml2016::RowRsid,
  Uniword::Generated::Wordprocessingml2016::SdtAppearance2016,
  Uniword::Generated::Wordprocessingml2016::SeparatorExtension,
  Uniword::Generated::Wordprocessingml2016::TableRsid,
  Uniword::Generated::Wordprocessingml2016::WebVideoProperty
]
puts "✅ Loaded #{w16_classes.size}/15 Word 2016 classes"
puts

# Summary
total = w14_classes.size + w15_classes.size + w16_classes.size
puts '=' * 80
puts 'Session 8 Autoload Test Complete!'
puts '=' * 80
puts "Total classes loaded: #{total}/60"
puts "  - Word 2010 (w14:): #{w14_classes.size}/25 ✅"
puts "  - Word 2013 (w15:): #{w15_classes.size}/20 ✅"
puts "  - Word 2016 (w16:): #{w16_classes.size}/15 ✅"
puts
puts 'All autoload indices working correctly! 🎉'
puts '=' * 80
