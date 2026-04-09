# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Signature line
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:signatureline>
    class SignatureLine < Lutaml::Model::Serializable
      attribute :issignatureline, :string
      attribute :id, :string
      attribute :provid, :string
      attribute :signinginstructionsset, :string
      attribute :allowcomments, :string
      attribute :showsigndate, :string
      attribute :suggestedsigner, :string
      attribute :suggestedsigner2, :string
      attribute :suggestedsigneremail, :string
      attribute :signinginstructions, :string

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
