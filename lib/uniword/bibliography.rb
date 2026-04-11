# frozen_string_literal: true

# Bibliography namespace module
# This file explicitly autoloads all Bibliography classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# Bibliography/citation support for Word documents
# Generated from OOXML schema

require 'lutaml/model'

module Uniword
  module Bibliography
    # Autoload all Bibliography classes (28)
    autoload :Author, 'uniword/bibliography/author'
    autoload :City, 'uniword/bibliography/city'
    autoload :Corporate, 'uniword/bibliography/corporate'
    autoload :Day, 'uniword/bibliography/day'
    autoload :Edition, 'uniword/bibliography/edition'
    autoload :First, 'uniword/bibliography/first'
    autoload :FirstName, 'uniword/bibliography/first_name'
    autoload :Guid, 'uniword/bibliography/guid'
    autoload :Issue, 'uniword/bibliography/issue'
    autoload :Last, 'uniword/bibliography/last'
    autoload :LastName, 'uniword/bibliography/last_name'
    autoload :Lcid, 'uniword/bibliography/lcid'
    autoload :LocaleId, 'uniword/bibliography/locale_id'
    autoload :Month, 'uniword/bibliography/month'
    autoload :NameList, 'uniword/bibliography/name_list'
    autoload :NameType, 'uniword/bibliography/author'
    autoload :Pages, 'uniword/bibliography/pages'
    autoload :Person, 'uniword/bibliography/person'
    autoload :Publisher, 'uniword/bibliography/publisher'
    autoload :RefOrder, 'uniword/bibliography/ref_order'
    autoload :Source, 'uniword/bibliography/source'
    autoload :SourceTag, 'uniword/bibliography/source_tag'
    autoload :SourceType, 'uniword/bibliography/source_type'
    autoload :Sources, 'uniword/bibliography/sources'
    autoload :Tag, 'uniword/bibliography/tag'
    autoload :Title, 'uniword/bibliography/title'
    autoload :Url, 'uniword/bibliography/url'
    autoload :VolumeNumber, 'uniword/bibliography/volume_number'
    autoload :Year, 'uniword/bibliography/year'
  end
end
