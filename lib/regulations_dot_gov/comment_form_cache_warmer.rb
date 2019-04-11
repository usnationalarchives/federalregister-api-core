class RegulationsDotGov::CommentFormCacheWarmer
  def perform
    start_time = Time.now

    HTTParty::HTTPCache.reading_from_cache(false) do
      client = RegulationsDotGov::Client.new

      options_to_load = Set.new
      documents.each do |document|
        begin
          comment_form = client.get_comment_form(document.document_number)

          options_to_load += comment_form.
            fields.
            select{|field| field.is_a?(RegulationsDotGov::CommentForm::Field::SelectField)}.
            map{|option| [option.name, option.option_parameters]}
        rescue RegulationsDotGov::Client::ResponseError
          #noop
        end
      end

      RegulationsDotGov::CommentForm::Field::ComboField::MAPPING.each do |field_name, values|
        values.each do |value|
          options_to_load << [field_name, {'dependentOnValue' => value}]
        end
      end

      options_to_load.each do |field_name, options|
        begin
          client.get_option_elements(field_name, options)
        rescue RegulationsDotGov::Client::ResponseError
          #noop
        end
      end
    end

    end_time = Time.now
    puts "Regulations.gov cache warm complete. {'start_time': #{start_time}, 'end_time': #{end_time}, 'duration': #{end_time - start_time}}"
  end

  def documents
    start_date = Date.current

    # load documents open for comment published in last 4 months
    (0..3).map do |i|
      FederalRegister::Article.search(
        :conditions => {
          :publication_date => {
            :lte => start_date.advance(:months => -1 * i).to_s(:iso),
            :gte => start_date.advance(:months => -1 * (i+1)).to_s(:iso),
          },
          :accepting_comments_on_regulations_dot_gov => 1
        },
        :per_page => 1000,
        :fields => [:document_number]
      )
    end.map(&:results).flatten
  end
end
