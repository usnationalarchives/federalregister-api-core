class Api::V1::TopicsController < ApiController
  def suggestions
    respond_to do |wants|
      wants.json do
        cache_for 1.day
          topics = Topic.named_approximately(params[:conditions][:term]).limit(10)
          render_json_or_jsonp topics.map{|t| basic_topic_data(t)}
      end
    end
  end

  private

  def basic_topic_data(topic)
    representation = TopicApiRepresentation.new(topic)
    fields = specified_fields || TopicApiRepresentation.all_fields
    Hash[ fields.map do |field|
      [field, representation.value(field)]
    end]
  end
end
