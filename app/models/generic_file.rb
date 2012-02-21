class GenericFile < ActiveFedora::Base
  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMethods

  has_metadata :name => "characterization", :type => FitsDatastream
  has_metadata :name => "descMetadata", :type => Rockhall::PbcoreDocument do |m|
  end
  has_metadata :name => "instMetadata", :type => Rockhall::PbcoreInstantiation do |m|
  end
  has_file_datastream :type => FileContentDatastream

  belongs_to :folder, :property => "isPartOf"

  def title
    descMetadata.main_title
  end
  delegate :contributor, :to       => :descMetadata
  delegate :creator, :to       => :descMetadata
  delegate :format_label, :to      => :characterization
  delegate :mime_type, :to         => :characterization
  delegate :file_size, :to         => :characterization
  delegate :last_modified, :to     => :characterization
  delegate :filename, :to          => :characterization
  delegate :original_checksum, :to => :characterization
  delegate :well_formed, :to       => :characterization
  delegate :file_title, :to        => :characterization
  delegate :file_author, :to       => :characterization
  delegate :page_count, :to => :characterization

  before_save :characterize

  ## Extract the metadata from the content datastream and record it in the characterization datastream
  def characterize
    if content.changed?
      characterization.content = content.extract_metadata
    end
  end
end
