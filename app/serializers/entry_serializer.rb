class EntrySerializer < ActiveModel::Serializer
  attributes :publication_date, :significant, :document_number, :docket_id, :presidential_document_type_id

  def docket_id
    #TODO: Fix
    # sql = <<-SQL
    #   (
    #     SELECT GROUP_CONCAT(DISTINCT docket_numbers.number SEPARATOR ' ')
    #     FROM docket_numbers
    #     WHERE docket_numbers.assignable_id = entries.id
    #       AND docket_numbers.assignable_type = 'Entry'
    #   )
    # SQL
    # Entry.connection.execute(sql)
  end

end
