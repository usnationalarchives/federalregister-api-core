require "spec_helper"
include ImagePipeline::ImageDescrunching

# copies image fixtues to tempfiles because the descrunch! command is destructive and will mutate the fixtures otherwise
def create_image_tempfile(path)
  tempfile = Tempfile.new
  IO.copy_stream(path, tempfile.path)
  tempfile
end

describe "GPO Image Descrunching" do

  it "descrunches a scrunched image with an offset of 18" do
    tempfile = create_image_tempfile('spec/fixtures/ER12JA01.048.eps')
    scrunched_image = File.open(tempfile)

    expect(gpo_scrunched_image?(scrunched_image.path)).to eq(true)
    descrunch!(scrunched_image.path)
  end

  it "descrunches an alternate scrunched image with an offset of 18" do
    tempfile = create_image_tempfile('spec/fixtures/ER11MR14.006')
    scrunched_image = File.open(tempfile)

    expect(gpo_scrunched_image?(scrunched_image.path)).to eq(true)
    descrunch!(scrunched_image.path)
  end

  it "it raises a DescrunchFailure error if the image cannot be descrunched" do
    offsets = [0]
    allow(self).to receive(:possible_offsets).and_return(offsets)

    tempfile = create_image_tempfile('spec/fixtures/ER11MR14.006')
    scrunched_image = File.open(tempfile)

    expect { descrunch!(scrunched_image.path) }.to raise_error(ImagePipeline::ImageDescrunching::DescrunchFailure)
  end

end
