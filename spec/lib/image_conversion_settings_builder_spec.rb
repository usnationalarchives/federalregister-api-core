require "spec_helper"

describe ImageConversionSettingsBuilder do

  it "builds the correct settings for a standard GPO SFTP-sourced image" do
    result = ImageConversionSettingsBuilder.new(
      'spec/support/ER16OC15.015.eps',
      ImageSource::GPO_SFTP,
      ImageStyle::LARGE,
    ).perform
    expect(result).to eq("-density 600 -monochrome -transparent white -resize 823x1235 -colors 8")
  end

end
