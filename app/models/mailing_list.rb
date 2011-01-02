class MailingList < ApplicationModel
  validates_presence_of :parameters, :title
end