class DeleteDuplicatesInDocketDocuments < ActiveRecord::Migration[6.0]

  def change

    ApplicationModel.transaction do
      DocketDocument.
        group(:id).
        having("count(*) > 1").
        count.
        each do |docket_document_id, count|
          iterations = count - 1
          iterations.times do
            ActiveRecord::Base.connection.execute "DELETE FROM docket_documents WHERE id = '#{docket_document_id}' LIMIT 1;"
          end
        end
    end

  end

end
