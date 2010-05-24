module Content
  class GraphicsExtractor
    require "content/graphics_extractor/entry"
    require "content/graphics_extractor/image"
    
    class MissingXML < StandardError; end
    require 'tmpdir'
    
    attr_reader :date
    
    def initialize(date)
      @date = date.class == String ? Date.parse(date) : date
    end
    
    def perform
      raise MissingXML.new unless File.exists?(entry_bulkdata_path)
      Dir.mktmpdir("entry_graphics").each do |tmp_dir|
        images.group_by(&:document_number).each do |document_number, images|
          entry = Content::GraphicsExtractor::Entry.new(document_number, :base_dir => tmp_dir)
          if entry.entry.nil?
            warn "entry #{document_number} not found!"
            next
          end
          
          images.each do |image|
            entry.associate_image(image)
          end
        end
      end
    end
    
    def entry_bulkdata_path
      "#{RAILS_ROOT}/data/bulkdata/FR-#{date.to_s(:iso)}.xml"
    end
    
    def images
      Image.all_images_in_file(entry_bulkdata_path)
    end
  end
end