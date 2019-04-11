class DocketNumber < ApplicationModel
  belongs_to :assignable, :polymorphic => true
  acts_as_list :scope => 'assignable_id = #{assignable_id} AND assignable_type = \'#{assignable_type}\''
end
