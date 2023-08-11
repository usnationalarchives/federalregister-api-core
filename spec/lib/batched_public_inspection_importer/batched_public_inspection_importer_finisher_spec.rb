require 'spec_helper'

describe Content::PublicInspectionImporter::BatchedPublicInspectionImporterFinisher do

  it "finalizes the import if there are no failures in the batch" do
    allow_any_instance_of(Content::PublicInspectionImporter::ApiClient).to receive(:logout)
    b = Sidekiq::Batch.new
    b.jobs do
    end

    importer = described_class.new
    allow(importer).to receive(:generate_toc)
    expect(PublicInspectionIndexer).to receive(:reindex!)
    expect(Content::PublicInspectionImporter::CacheManager).to receive(:manage_cache).twice
    expect(importer).to receive(:generate_toc).twice

    importer.on_complete(
      Sidekiq::Batch::Status.new(b.bid),
      {
        "start_time"    => Time.current.to_s(:iso),
        "session_token" => 'fake_token'
      }
    )
  end

end
