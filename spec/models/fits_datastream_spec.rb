require 'spec_helper'

describe FitsDatastream do
  before do
    @file = GenericFile.new
    @file.add_file_datastream(File.new(Rails.root + 'spec/fixtures/world.png'), :dsid=>'content')
    @file.characterize
    @file.save
  end
  it "should have a format label" do
    @file.format_label.should include("Portable Network Graphics")
  end
  it "should have a mime type" do
    @file.mime_type.should include("image/png")
  end
  it "should have a file size" do
    @file.file_size.should include("4218")
  end
  it "should have a last modified timestamp" do
    @file.last_modified.should_not include("")
  end
  it "should have a filename" do
    @file.filename.should_not include("")
  end
  it "should have a checksum" do
    @file.original_checksum.should include("28da6259ae5707c68708192a40b3e85c")
  end
end

