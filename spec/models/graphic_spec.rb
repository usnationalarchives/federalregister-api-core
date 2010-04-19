=begin Schema Information

 Table name: graphics

  id                   :integer(4)      not null, primary key
  identifier           :string(255)
  usage_count          :integer(4)      default(0), not null
  graphic_file_name    :string(255)
  graphic_content_type :string(255)
  graphic_file_size    :integer(4)
  graphic_updated_at   :datetime
  created_at           :datetime
  updated_at           :datetime
  inverted             :boolean(1)

=end Schema Information

require 'spec_helper'

describe Graphic do
  it { should have_many(:usages) }
  it { should have_many(:entries) }
end
