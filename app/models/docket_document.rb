class DocketDocument < ApplicationModel
  serialize :metadata, Hash
  belongs_to :docket
end
