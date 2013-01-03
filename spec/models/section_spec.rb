# == Schema Information
#
# Table name: sections
#
#  id                    :integer(4)      not null, primary key
#  title                 :string(255)
#  slug                  :string(255)
#  position              :integer(4)
#  description           :text(16777215)
#  relevant_cfr_sections :text(16777215)
#  created_at            :datetime
#  updated_at            :datetime
#  creator_id            :integer(4)
#  updater_id            :integer(4)
#

require 'spec_helper'

describe Section do
  it { should have_many(:agencies_sections) }
  it { should have_many(:agencies) }
end
