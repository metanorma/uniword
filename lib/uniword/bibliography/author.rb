# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Bibliography
    # Name type wrapper (CT_NameType) for role-specific author elements
    #
    # Used by Artist, BookAuthor, Compiler, Composer, Conductor, Counsel,
    # Director, Editor, Interviewee, Interviewer, Inventor, ProducerName,
    # Translator, Writer - each contains a single NameList.
    class NameType < Lutaml::Model::Serializable
      attribute :name_list, NameList

      xml do
        namespace Uniword::Ooxml::Namespaces::Bibliography
        mixed_content
        map_element 'NameList', to: :name_list, render_nil: false
      end
    end

    # Author information container for bibliography sources
    #
    # XSD: CT_AuthorType - contains a choice of role-specific sub-elements.
    # Also serves as CT_NameOrCorporateType (NameList or Corporate) when
    # used as the inner Author/Performer role element.
    #
    # Element: <b:Author>
    class Author < Lutaml::Model::Serializable
      # CT_NameOrCorporateType (direct children for inner role usage)
      attribute :name_list, NameList
      attribute :corporate, :string

      # CT_NameType role elements (each contains a NameList)
      attribute :artist, NameType
      attribute :book_author, NameType
      attribute :compiler, NameType
      attribute :composer, NameType
      attribute :conductor, NameType
      attribute :counsel, NameType
      attribute :director, NameType
      attribute :editor, NameType
      attribute :interviewee, NameType
      attribute :interviewer, NameType
      attribute :inventor, NameType
      attribute :producer_name, NameType
      attribute :translator, NameType
      attribute :writer, NameType

      # CT_NameOrCorporateType role elements (recursive)
      attribute :author, Author
      attribute :performer, Author

      xml do
        element 'Author'
        namespace Uniword::Ooxml::Namespaces::Bibliography
        mixed_content

        map_element 'NameList', to: :name_list, render_nil: false
        map_element 'Corporate', to: :corporate, render_nil: false
        map_element 'Artist', to: :artist, render_nil: false
        map_element 'Author', to: :author, render_nil: false
        map_element 'BookAuthor', to: :book_author, render_nil: false
        map_element 'Compiler', to: :compiler, render_nil: false
        map_element 'Composer', to: :composer, render_nil: false
        map_element 'Conductor', to: :conductor, render_nil: false
        map_element 'Counsel', to: :counsel, render_nil: false
        map_element 'Director', to: :director, render_nil: false
        map_element 'Editor', to: :editor, render_nil: false
        map_element 'Interviewee', to: :interviewee, render_nil: false
        map_element 'Interviewer', to: :interviewer, render_nil: false
        map_element 'Inventor', to: :inventor, render_nil: false
        map_element 'Performer', to: :performer, render_nil: false
        map_element 'ProducerName', to: :producer_name, render_nil: false
        map_element 'Translator', to: :translator, render_nil: false
        map_element 'Writer', to: :writer, render_nil: false
      end
    end
  end
end
