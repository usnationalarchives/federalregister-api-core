=begin Schema Information

 Table name: sections

  id                    :integer(4)      not null, primary key
  title                 :string(255)
  slug                  :string(255)
  position              :integer(4)
  description           :text
  relevant_cfr_sections :text
  created_at            :datetime
  updated_at            :datetime
  creator_id            :integer(4)
  updater_id            :integer(4)

=end Schema Information

require 'spec_helper'

describe Section do
  it { should have_many(:agencies_sections) }
  it { should have_many(:agencies) }
end
