class PathGenerator
  # Load up all the routing...
  include ActionController::UrlWriter
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

  def about_section_paths(n)
    Section.all.map do |section|
      about_section_path(section)
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
  
  def massage_to_n(array,n)
    if array.size == n
      array.sort_by{rand}
    elsif array.size > n
      array.sort_by{rand}[0,n]
    else
      massage_to_n(array * (n.to_f / array.size).ceil,n)
    end
  end
end

puts PathGenerator.new.generate(1000,
  {
    :root          => 30,
    :entry         => [60,2],
    :agency        => 10,
    :regulation    => 10,
  }
)