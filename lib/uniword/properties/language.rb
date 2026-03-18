# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Language code value
    #
    # Represents language codes (e.g., "en-US", "zh-CN", "ar-SA")
    class LanguageValue < Lutaml::Model::Type::String
    end

    # Language settings for run text
    #
    # Represents <w:lang> element with language codes for different scripts.
    #
    # @example Creating language settings
    #   lang = Language.new(
    #     val: 'en-US',
    #     east_asia: 'zh-CN',
    #     bidi: 'ar-SA'
    #   )
    class Language < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :val, LanguageValue          # Latin/default script language
      attribute :east_asia, LanguageValue    # East Asian script language
      attribute :bidi, LanguageValue         # Bidirectional script language

      xml do
        element 'lang'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
        map_attribute 'eastAsia', to: :east_asia
        map_attribute 'bidi', to: :bidi
      end
    end
  end
end
