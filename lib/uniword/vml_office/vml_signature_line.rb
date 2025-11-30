# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Signature line in VML
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:signatureline>
    class VmlSignatureLine < Lutaml::Model::Serializable
      attribute :issignatureline, String
      attribute :id, String
      attribute :provid, String
      attribute :signinginstructionsset, String
      attribute :allowcomments, String
      attribute :showsigndate, String
      attribute :suggestedsigner, String
      attribute :suggestedsigneremail, String
      attribute :signinginstructions, String

      xml do
        element 'signatureline'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'issignatureline', to: :issignatureline
        map_attribute 'id', to: :id
        map_attribute 'provid', to: :provid
        map_attribute 'signinginstructionsset', to: :signinginstructionsset
        map_attribute 'allowcomments', to: :allowcomments
        map_attribute 'showsigndate', to: :showsigndate
        map_attribute 'suggestedsigner', to: :suggestedsigner
        map_attribute 'suggestedsigneremail', to: :suggestedsigneremail
        map_attribute 'signinginstructions', to: :signinginstructions
      end
    end
  end
end
