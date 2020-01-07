class CannedSearch < ApplicationModel
  include Shared::DoesSlug[:based_on => :title]

  belongs_to :section
  validates_presence_of :section, :title, :description, :search_conditions

  acts_as_list :scope => :section_id
  scope :active, -> { where(active: true) }
  scope :in_order, -> { order("position") }
  scope :inactive, -> { where(active: 0) }
  scope :alphabetically, -> { order("canned_searches.title") }

  def new_position=(new_pos)
    insert_at(new_pos)
  end

  attr_reader :search_url
  def search_url=(search_url)
    @search_url = search_url
    if search_url.present?
      search_parameters = search_url.sub(/.*\?/, '')
      self.search_conditions = Rack::Utils.parse_nested_query(search_parameters)['conditions'].to_json
    end
    search_url
  end

  #NOTE: Thinking Sphinx v3 is much stricter about types and will throw errors if a string value like ["1"] is passed in lieu of its integer counterpart
  def search_conditions
    conditions = JSON.parse(self['search_conditions']||'{}')

    EntriesController::INTEGER_PARAMS_NEEDING_DESERIALIZATION.each do |param_name|
      ids = conditions[param_name]
      if ids.present?
        conditions[param_name] = Array.wrap(ids).map(&:to_i)
      end
    end

    conditions
  end

  def search
    @search ||= EntrySearch.new(:conditions => search_conditions, :order => "newest")
  end

  def documents_in_last(time_frame)
    conditions = search_conditions.merge(
      :publication_date => {
        :gte => Issue.current.publication_date - time_frame
      }
    )
    EntrySearch.new(:conditions => conditions, :metadata_only => true).count
  end

  def documents_with_open_comment_periods
    conditions = search_conditions.merge(
      :comment_date => {
        :gte => Date.today
      }
    )
    EntrySearch.new(:conditions => conditions, :metadata_only => true).count
  end
end
