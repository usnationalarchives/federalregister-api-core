class Topic < ActiveRecord::Base
  has_many :topic_assignments
  has_many :topics, :through => :topic_assignments
end