class AssignPrimaryKeyToDocketDocuments < ActiveRecord::Migration[6.0]

  def up
    execute "ALTER TABLE docket_documents ADD PRIMARY KEY (id);"
  end

end
