# frozen_string_literal: true

module Uniword
  module Validation
    module Checkers
      autoload :InternalLinkChecker, "#{__dir__}/checkers/internal_link_checker"
      autoload :ExternalLinkChecker, "#{__dir__}/checkers/external_link_checker"
      autoload :FileReferenceChecker,
               "#{__dir__}/checkers/file_reference_checker"
      autoload :FootnoteReferenceChecker,
               "#{__dir__}/checkers/footnote_reference_checker"
    end
  end
end
