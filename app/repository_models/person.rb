require 'active_fedora/registered_attributes'

class Person < ActiveFedora::Base
  include ActiveFedora::RegisteredAttributes

  has_metadata name: "descMetadata", type: PersonMetadataDatastream, control_group: 'M'

  belongs_to :profile, property: :has_profile, class_name: 'Collection'

  attribute :name,
      datastream: :descMetadata, multiple: false

  attribute :preferred_email,
      datastream: :descMetadata, multiple: false

  attribute :alternate_email,
      datastream: :descMetadata, multiple: false

  attribute :date_of_birth,
      datastream: :descMetadata, multiple: false

  attribute :title,
      datastream: :descMetadata, multiple: false

  attribute :campus_phone_number,
      datastream: :descMetadata, multiple: false

  attribute :alternate_phone_number,
      datastream: :descMetadata, multiple: false

  attribute :personal_webpage,
      datastream: :descMetadata, multiple: false

  attribute :blog,
      datastream: :descMetadata, multiple: false

  attribute :gender,
      datastream: :descMetadata, multiple: false

  def first_name
    name_parser.given
  end

  def last_name
    name_parser.family
  end

  def name_parser
    Namae.parse(self.name).first
  end

  def create_profile(depositor)
    collection = Collection.new(title: "My Profile")
    collection.apply_depositor_metadata(depositor.user_key)
    collection.read_groups = [Sufia::Models::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
    collection.save!
    self.profile = collection
    self.save!
    self.profile
  end

end
