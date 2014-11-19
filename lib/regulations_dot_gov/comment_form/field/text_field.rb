class RegulationsDotGov::CommentForm::Field::TextField < RegulationsDotGov::CommentForm::Field
  def max_length
    raw = attributes["maxLength"].try(:to_i)

    if raw == -1
      2000
    else
      raw
    end
  end
end
