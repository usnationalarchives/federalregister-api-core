require 'spec_helper'

describe GpoGraphic do
  let(:attachment) { File.new(Rails.root + 'spec/fixtures/empty_example_file') }

  it "returns the correct attachment url when graphic usages are not present" do
    result = GpoGraphic.new(graphic: attachment).graphic.url
    host = "https://#{SETTINGS['s3_host_aliases']['private_images']}"
    expect(result).to start_with(host)
  end

  it "returns the correct attachment url when graphic usages are" do
    result = GpoGraphic.new(graphic: attachment, gpo_graphic_usages: [GpoGraphicUsage.new]).graphic.url
    host = "https://#{SETTINGS['s3_host_aliases']['public_images']}"
    expect(result).to start_with(host)
  end

  context "specific styles based on model attributs" do
    it "if not sourced via ecfr.gov, only creates 'large' and 'original' styles" do
      result = GpoGraphic.new(sourced_via_ecfr_dot_gov: false ).graphic.styles.values.map(&:name)
      expect(result).to match_array([:original_png, :large])
    end

    it "only creates 'pdf' and 'ecfr' styles" do
      result = GpoGraphic.new(sourced_via_ecfr_dot_gov: true ).graphic.styles.values.map(&:name)
      expect(result).to match_array([:ecfr])
    end
  end

end

