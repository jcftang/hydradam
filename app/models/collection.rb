require "psu-customizations"

class Collection < ActiveFedora::Base
  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMethods

  has_metadata :name => "descMetadata", :type => GammaRDFDatastream

  belongs_to :user, :property => "creator"
  has_many :generic_files, :property => "hasPart"

  delegate :title, :to => :descMetadata
  delegate :creator, :to => :descMetadata
  delegate :hasPart, :to => :descMetadata
end
