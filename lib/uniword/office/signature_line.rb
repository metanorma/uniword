# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Signature line
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:signatureline>
    class SignatureLine < Lutaml::Model::Serializable
      attribute :issignatureline, String
      attribute :id, String
      attribute :provid, String
      attribute :signinginstructionsset, String
      attribute :allowcomments, String
      attribute :showsigndate, String
      attribute :suggestedsigner, String
      attribute :suggestedsigner2, String
      attribute :suggestedsigneremail, String
      attribute :signinginstructions, String

      xml do
        element 'signatureline'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'issignatureline', to: :issignatureline
        map_attribute 'id', to: :id
        map_attribute 'provid', to: :provid
        map_attribute 'signinginstructionsset', to: :signinginstructionsset
        map_attribute 'allowcomments', to: :allowcomments
        map_attribute 'showsigndate', to: :showsigndate
        map_attribute 'suggestedsigner', to: :suggestedsigner
        map_attribute 'suggestedsigner2', to: :suggestedsigner2
        map_attribute 'suggestedsigneremail', to: :suggestedsigneremail
        map_attribute 'signinginstructions', to: :signinginstructions
      end
    end
  end
end
