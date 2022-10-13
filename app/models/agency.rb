class Agency < ApplicationModel
  include Shared::DoesSlug[:based_on => :name]

  module AssociationExtensions
    def excluding_parents
      agencies = self.compact.uniq

      owner = proxy_association.owner

      # Public Inspection Documents only get a parent agency associated when
      #  it is a co-publication between the parent and child agencies, so the parent
      #  agency should never be excluded
      if owner.is_a?(PublicInspectionDocument) ||
          owner.agency_names.any?{|agency_name| agency_name && agency_name.name =~ /Office of the Secretary/i}
        agencies
      else
        parent_agency_ids = agencies.map(&:parent_id).compact
        agencies.reject{|a| parent_agency_ids.include?(a.id) }
      end
    end
  end

  # cabinet level agencies and the EPA
  # excludes things like the dept of the army, etc
  # as they don't produce many FR documents
  AGENCIES_IN_NAV_AGENCY_IDS = [12, 54, 103, 126, 136, 145, 221, 227, 228, 253, 268, 271, 476, 492, 497, 520]

  has_many :agencies_sections
  has_many :sections, :through => :agencies_sections
  has_many :agency_names
  has_many :agency_name_assignments, :through => :agency_names
  has_many :entries, -> { distinct}, :through => :agency_name_assignments,
    source: :assignable, source_type: 'Entry'
  has_many :regulatory_plans, -> { distinct}, :through => :agency_name_assignments,
    source: :assignable, source_type: 'RegulatoryPlan'

  has_many :fr_index_agency_statuses

  has_many :children, :class_name => 'Agency', :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => 'Agency'

  scope :in_navigation, -> { where("id IN (?)", AGENCIES_IN_NAV_AGENCY_IDS) }

  has_attached_file :logo,
                    :styles => { :thumb => "100", :small => "140", :medium => "245", :large => "580", :full_size => "" },
                    :processors => [:thumbnail],
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => Rails.application.secrets[:aws][:access_key_id],
                      :secret_access_key => Rails.application.secrets[:aws][:secret_access_key],
                      :s3_region => 'us-east-1'
                    },
                    :s3_host_alias => SETTINGS['s3_host_aliases']['agency_logos'],
                    :s3_protocol => 'https',
                    :bucket => SETTINGS["s3_buckets"]["agency_logos"],
                    :path => ":id/:style.:extension",
                    :url => ':s3_alias_url'
  do_not_validate_attachment_file_type :logo

  validates_uniqueness_of :name, case_sensitive: true
  validates_presence_of :name

  validates_format_of :url, :with => /\Ahttps?:\/\/\S+\z/, :allow_blank => true
  serializable_column :entries_1_year_weekly, :entries_5_years_monthly, :entries_all_years_quarterly, :related_topics_cache

  scope :with_logo, -> { where("agencies.logo_file_name IS NOT NULL") }
  scope :alphabetically, -> { order("agencies.name")}
  scope :active, -> { where(active: true) }

  # consider using sphinx instead...
  def self.named_approximately(name)
    return [] if name.blank?
    words = name.downcase.split(/[^a-z]+/) - %w(a and & in for of on s the)

    if words.empty?
      scoped(:conditions => {:id => nil}) # null scope
    else
      condition_sql = "(" + words.map{"agencies.name REGEXP ?"}.join(" AND ") + ") OR (" + words.map{"agencies.short_name REGEXP ?"}.join(" AND ") + ")"
      # '[[:<:]]' is MySQL regex for 'beginning of word'
      bind_params = words.map{|word|"[[:<:]]#{Regexp.escape(word)}"} * 2
      agencies = scoped(
        :conditions => [
          condition_sql, *bind_params
        ],
        :order => "agencies.name"
      )
    end
  end

  def to_param
    slug
  end

  def name_and_short_name
    if short_name.present?
      "#{name} (#{short_name})"
    else
      name
    end
  end

  def sidebar_name
    # FIXME: remove downcase and capitalize_most_words - just fixing agency wierdness for now
    self.name.downcase.capitalize_most_words.gsub(/^Department of(?: the)? /,'')
  end

  def entry_counts_since(range_type)
    date = case range_type
      when 'week'
        1.week.ago
      when 'month'
        1.month.ago
      when 'quarter'
        3.months.ago
      when 'year'
        1.year.ago
      end

    entries.count(:conditions => ["publication_date >= ?", date])
  end

  def s3_attachment_paths
    if logo.present?
      logo.styles.map{|style_metadata| "/#{style_metadata.last.attachment.path}" }
    else
      []
    end
  end
end
