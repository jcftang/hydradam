class ExiftoolDatastream < ActiveFedora::RdfxmlRDFDatastream

end


class RDF::EXIF::System < RDF::Vocabulary("http://ns.exiftool.ca/System/1.0/")
  property :FileSize 
end

class RDF::EXIF::File < RDF::Vocabulary("http://ns.exiftool.ca/File/1.0/")
  property :FileType
  property :MIMEType
end

class RDF::EXIF::Composite < RDF::Vocabulary("http://ns.exiftool.ca/Composite/1.0/")
  property :ImageSize
  property :Duration
end

class RDF::EXIF::Quicktime < RDF::Vocabulary("http://ns.exiftool.ca/QuickTime/QuickTime/1.0/")
  property :Version
  property :CreateDate
  property :ModifyDate
  property :TimeScale
  property :Duration
  property :PreferredRate
  property :PreferredVolume
  property :MatrixStructure
  property :PreviewTime
  property :PreviewDuration
  property :PosterTime
  property :SelectionTime
  property :SelectionDuration
  property :CurrentTime
  property :NextTrackID
  property :HandlerType
  property :ComAppleFinalcutstudioMediaUuid 

  def self.Track i
    RDF::Vocabulary.new("http://ns.exiftool.ca/QuickTime/Track#{i}/1.0/")
  end

  class Track1 < RDF::Vocabulary("http://ns.exiftool.ca/QuickTime/Track1/1.0/")
    property :VideoFrameRate
    property :ImageWidth
    property :ImageHeight
    property :BitDepth
    property :CompressorName
  end

end

class RDF::EXIF::XMP < RDF::Vocabulary('http://ns.exiftool.ca/XMP/XMP-xmp/1.0/')
  property :CreateDate
end

class RDF::EXIF::XMP::DC < RDF::Vocabulary('http://ns.exiftool.ca/XMP/XMP-dc/1.0/')
  property :Creator
end

class RDF::EXIF::RIFF < RDF::Vocabulary("http://ns.exiftool.ca/RIFF/RIFF/1.0/")
  property :Encoding
  property :SampleRate

end

class ExiftoolDatastream 
  register_vocabularies RDF::EXIF::File, RDF::EXIF::Quicktime, RDF::EXIF::System, RDF::EXIF::Quicktime::Track1
  rdf_subject { |ds| "info:fedora/#{ds.pid}/content" }

  map_predicates do |map|
    map.qt_create_date(:to => :CreateDate, :in => RDF::EXIF::Quicktime) do |index|
      index.as :displayable, :facetable
    end

    map.qt_duration(:to => :Duration, :in => RDF::EXIF::Quicktime) do |index|
      index.as :facetable
    end

    map.uuid(:to => :ComAppleFinalcutstudioMediaUuid, :in => RDF::EXIF::Quicktime) do |index|
      index.as :searchable, :displayable
    end

    map.xmp_create_date(:to => :CreateDate, :in => RDF::EXIF::XMP) do |index|
      index.as :displayable, :facetable
    end

    map.creator(:to => :Creator, :in => RDF::EXIF::XMP::DC) do |index|
      index.as :displayable, :facetable, :searchable
    end

    map.type(:to => :MIMEType, :in => RDF::EXIF::File) do |index|
      index.as :displayable, :facetable
    end

    map.fps(:to => :VideoFrameRate, :in => RDF::EXIF::Quicktime::Track1) do |index|
      index.as :displayable
    end

    map.width(:to => :ImageWidth, :in => RDF::EXIF::Quicktime::Track1) do |index|
      index.as :facetable
    end

    map.height(:to => :ImageHeight, :in => RDF::EXIF::Quicktime::Track1) do |index|
      index.as :facetable
    end

    map.bit_depth(:to => :BitDepth, :in => RDF::EXIF::Quicktime::Track1) do |index|
      index.as :facetable
    end

    map.qt_compressor_name(:to => :CompressorName, :in => RDF::EXIF::Quicktime::Track1) do |index|
      index.as :facetable
    end

    map.size(:to => :ImageSize, :in => RDF::EXIF::Composite) do |index|
      index.as :displayable
    end

    map.duration(:to => :Duration, :in => RDF::EXIF::Composite) do |index|
      index.as :displayable, :facetable
    end

    map.sample_rate(:to => :SampleRate, :in => RDF::EXIF::RIFF) do |index|
      index.as :displayable, :facetable
    end

    map.encoding(:to => :Encoding, :in => RDF::EXIF::RIFF) do |index|
      index.as :displayable, :facetable
    end

  end
end

