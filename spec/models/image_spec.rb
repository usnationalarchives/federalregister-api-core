require "spec_helper"

describe Image do

  context "image saving" do
    it "creates the appropriate image variants" do
      metadata_attributes = [:image_size, :image_height, :image_sha, :image_width, ]
      image = Image.create!(
        identifier: 'ER16OC15.015',
        image: File.open('spec/support/ER16OC15.015.eps'),
        source_id: ImageSource::GPO_SFTP.id
      ) 
      metadata_attributes.each do |attribute|
        expect(image.send(attribute)).to be_truthy
      end
      expect(image).to have_attributes(
        image_file_name: "#{image.identifier}.eps",
        image_content_type: "image/ps"
      )

      results = image.image_variants
      expect(results).to match_array([
        have_attributes(identifier: image.identifier, image_file_name: "#{image.identifier}_original_size.png", style: "original_size", image_content_type: "image/png"),
        have_attributes(identifier: image.identifier, image_file_name: "#{image.identifier}_medium.png", style: "medium", image_content_type: "image/png"),
        have_attributes(identifier: image.identifier, image_file_name: "#{image.identifier}_large.png", style: "large", image_content_type: "image/png"),
      ])
      results.each do |result|
        metadata_attributes.each do |attribute|
          expect(result.send(attribute)).to be_truthy
        end
      end
    end
  end

end
