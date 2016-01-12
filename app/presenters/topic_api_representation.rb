class TopicApiRepresentation < ApiRepresentation
  field(:name)
  field(:slug)
  field(:url, :select => :slug) {|topic| topic_url(topic)}
end
