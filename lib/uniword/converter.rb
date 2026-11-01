# frozen_string_literal: true

module Uniword
  # Format converters beyond the docx/mhtml/html paths handled by
  # FormatConverter. Currently hosts the plain-text editing round
  # trip (Markdown / AsciiDoc) built on the optional Coradoc gems.
  module Converter
    autoload :PlainText, "uniword/converter/plain_text"
    autoload :PlainTextResult, "uniword/converter/plain_text_result"
  end
end
