# Content::CfrPartsImporter.import(2010, :title => 5, :volume => 2)

module Content
  class CfrPartsImporter
    def self.import(options)
      options.symbolize_keys!

      years   = options[:year]   || all_years

      years.to_a.each do |year|
        titles  = options[:title]  || all_titles_for_year(year)

        titles.to_a.each do |title|
          volumes = options[:volume] || all_volumes_for_year_and_title(year,title)

          volumes.to_a.each do |volume|
            new(year, title, volume).import
          end
        end
      end
    end

    def self.all_years
      Dir.entries(File.join(Rails.root, 'data', 'cfr')).
        reject{|name| name =~ /^\./}.
        map(&:to_i).
        sort
    end

    def self.all_titles_for_year(year)
      Dir.entries(File.join(Rails.root, 'data', 'cfr', year.to_s)).
        reject{|name| name =~ /^\./}.
        map{|name| name.sub(/^title-/,'').to_i}.
        sort
    end

    def self.all_volumes_for_year_and_title(year, title)
      Dir.entries(File.join(Rails.root, 'data', 'cfr', year.to_s, "title-#{title}")).
        reject{|name| name =~ /^\./}.
        map{|name| name.sub(/^.*vol/,'').sub(/\.xml$/,'').to_i}.
        sort
    end

    attr_accessor :year, :title, :volume

    def initialize(year, title, volume)
      @year = year
      @title = title
      @volume = volume
    end

    def import
      part_nodes.each do |part_node|
        raw_part = part_node.xpath('./EAR').first.try(:content)
        next unless raw_part

        match = raw_part.match(/^Pt. (\d+)$/) # skipping items like 'Pt. 752, Nt.'
        next unless match

        part = match[1]
        cfr_part = CfrPart.find_or_initialize_by(
          year:  year,
          title: title,
          part:  part
        )
        cfr_part.volume = volume

        raw_name = part_node.xpath('./HD[@SOURCE="HED"]').first.try(:content)
        cfr_part.name = raw_name.sub(/^.*?—/,'')

        cfr_part.save!
      end
    end

    def part_nodes
      # root_node.xpath('//PART[not(ancestor::PART)][EAR]')
      root_node.xpath('//PART[EAR]')
    end

    def root_node
      doc = Nokogiri::XML(open(file_path))
      doc.root
    end

    def file_path
      File.join(Rails.root, 'data', 'cfr', year.to_s, "title-#{title}", "CFR-#{year}-title#{title}-vol#{volume}.xml")
    end

  end
end
