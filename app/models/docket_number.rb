# == Schema Information
#
# Table name: docket_numbers
#
#  id              :integer(4)      not null, primary key
#  number          :string(255)
#  assignable_type :string(255)
#  assignable_id   :integer(4)
#  position        :integer(4)      default(0), not null
#

class DocketNumber < ApplicationModel
  belongs_to :assignable, :polymorphic => true
  acts_as_list :scope => 'assignable_id = #{assignable_id} AND assignable_type = \'#{assignable_type}\''
end
