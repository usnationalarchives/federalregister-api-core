class ResyncIndexAuditing < ActiveRecord::Migration[6.0]
  def change
    ElasticsearchIndexer.resync_index_auditing
  end
end
