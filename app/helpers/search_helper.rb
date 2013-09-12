module SearchHelper
  PLURAL_FILTERS = [:topic_ids] # agency_ids; comment back in to be able to remove individual agencies
  
  def search_adding_filter(condition,value)
    conditions = params.dup[:conditions] || {}
    
    if PLURAL_FILTERS.include?(condition)
      conditions[condition] ||= []
      conditions[condition] << value
    else
      conditions[condition] = value
    end
    params.except(:quiet, :all, :facet).recursive_merge(:page => nil, :action => :show, :conditions => conditions)
  end
  
  def search_removing_filter(condition, value)
    conditions = params.dup[:conditions].with_indifferent_access || {}
    
    if PLURAL_FILTERS.include?(condition)
      conditions[condition] ||= []
      conditions[condition] = conditions[condition] - [value.to_s]
    else
      conditions.except!(condition)
    end
    params.except(:quiet).merge(:page => nil, :action => :show, :conditions => conditions)
  end
  
  def working_search_example(search_term)
    content_tag(:code) do
      link_to search_term, entries_search_path(:conditions => {:term => search_term}), :target => "_blank"
    end
  end
  
  def entry_count_for_search_term(search_term)
    EntrySearch.new(:conditions => {:term => search_term}).count
  end
  
  def conditions_for_subscription(search)
    search.valid_conditions.except(:publication_date)
  end
  
  def search_suggestion_title(suggestion, search)
    search_filters = search.filter_summary
    parts = suggestion.filter_summary.map do |suggested_filter|
      if search_filters.include?(suggested_filter)
        suggested_filter
      else
        content_tag(:strong, suggested_filter)
      end
    end
    
    # TODO: bolding of spelling corrections
    if suggestion.term.present?
      term = if suggestion.prior_term
               SpellChecker.new(:template => self).highlight_corrections(suggestion.prior_term)
             else
               h(suggestion.term)
             end
      parts << "matching " + content_tag(:span, term, :class => "term")
    end
    
    parts.to_sentence
  end
  
  
end
