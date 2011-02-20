class EntryEmail < ApplicationModel
  belongs_to :entry
  
  validates_presence_of :sender
  validates_numericality_of :num_recipients, :greater_than => 0
  validates_presence_of :entry, :remote_ip, :recipients, :sender_hash
  
  before_validation :calculate_num_recipients
  after_create :deliver_email
  
  attr_reader :sender
  def sender=(sender)
    @sender = sender
    if sender.present?
      email_hash = @sender
      self.sender_hash = 20.times { email_hash = Digest::SHA512.hexdigest(email_hash) }
    else
      self.sender_hash = nil
    end
    @sender
  end
  
  attr_reader :recipients
  def recipients=(value)
    if value.is_a?(Array)
      @recipients = value
    else
      @recipients = value.to_s.split(/\s*,\s*/)
    end
    
    @recipients
  end
  
  private
  
  def calculate_num_recipients
    self.num_recipients = @recipients.try(:count) || 0
  end
  
  def deliver_email
    Mailer.deliver_entry_email(self)
  end
end