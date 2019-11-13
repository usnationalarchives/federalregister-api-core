class PathGenerator
  # Load up all the routing...
  include Rails.application.routes.url_helpers
  include ApplicationHelper
  include RouteBuilder

  def generate(grand_total_n, counts_by_type)
    paths = []
    counts_by_type.each_pair do |type, counts|
      total_n = counts.to_a.first
      unique_n = counts.to_a.last
      paths += massage_to_n(send("#{type}_paths", unique_n), total_n)
    end

    massage_to_n(paths, grand_total_n)
  end

  private

  def root_paths(n)
    [root_path]
  end

  def section_paths(n)
    Section.all.map do |section|
      section_path(section)
    end
  end

  def entry_paths(n)
    Entry.random_selection(n).map do |entry|
      entry_path(entry)
    end
  end

  def date_paths(n)
    Entry.random_selection(n).map do |entry|
      entries_by_date_path(entry.publication_date)
    end
  end

  def topic_by_letter_paths(n)
    ('a' .. 'z').map do |letter|
      topics_by_letter_path(letter)
    end
  end

  def topic_paths(n)
    Topic.random_selection(n).map do |topic|
      topic_path(topic)
    end
  end

  def agencies_paths(n)
    [agencies_path]
  end

  def agency_paths(n)
    Agency.random_selection(n).map do |agency|
      agency_path(agency)
    end
  end

  def regulation_paths(n)
    RegulatoryPlan.random_selection(n).map do |regulatory_plan|
      regulatory_plan_path(regulatory_plan)
    end
  end

  def entries_search_paths(n)
    ret = []
    n.times do |i|
      ret << entries_search_path(:conditions => {:term => random_search_phrase})
    end
    ret
  end

  def regulatory_plans_search_paths(n)
    ret = []
    n.times do |i|
      ret << regulatory_plans_search_path(:conditions => {:term => random_search_phrase})
    end
    ret
  end

  def events_search_paths(n)
    ret = []
    n.times do |i|
      ret << events_search_path(:conditions => {:term => random_search_phrase})
    end
    ret
  end

  def massage_to_n(array,n)
    if array.size == n
      array.sort_by{rand}
    elsif array.size > n
      array.sort_by{rand}[0,n]
    else
      massage_to_n(array * (n.to_f / array.size).ceil,n)
    end
  end

  private

  def random_search_phrase
    search_phrases[rand(search_phrases.size)]
  end

  def search_phrases
    @phrases ||= File.read("#{Rails.root}/data/search_phrases.txt").split("\n")
  end
end

puts PathGenerator.new.generate(10000,
  {
    :entries_search          => 4000,
    :events_search           => 500,
    :regulatory_plans_search => 500,
  }
)