class PilAgencyLetter < ApplicationModel
  belongs_to :public_inspection_document

  has_attached_file :file,
                    :storage => :s3,
                    :s3_credentials => {
                      :access_key_id     => Rails.application.secrets[:aws][:access_key_id],
                      :secret_access_key => Rails.application.secrets[:aws][:secret_access_key],
                      :s3_region => 'us-east-1'
                    },
                    :s3_host_alias => Settings.app.aws.s3.host_aliases.public_inspection,
                    :s3_protocol => 'https',
                    :bucket => Settings.app.aws.s3.buckets.public_inspection,
                    :path => "pil_agency_letters/:id/:filename",
                    :url => ':s3_alias_url'

  do_not_validate_attachment_file_type :file
  validates_presence_of :public_inspection_document, :file
  validates_attachment_content_type :file, :content_type =>[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordproces',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
end
