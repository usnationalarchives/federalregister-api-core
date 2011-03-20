class EntryEmail < ApplicationModel
  belongs_to :entry
  
  attr_accessible :sender, :recipients, :message
  
  validates_presence_of :sender
  validates_presence_of :entry, :remote_ip, :recipients
  validate :sender_email_is_valid, :if => Proc.new{|e| e.sender.present?}
  validate :recipient_emails_are_valid, :if => Proc.new{|e| e.recipients.present?}
  validate :no_more_than_10_recipients
  
  before_validation :calculate_num_recipients
  after_create :deliver_email
  
  attr_accessor :message
  
  attr_reader :sender
  def sender=(sender)
    @sender = sender.to_s.strip
    if sender.present?
      email_hash = "#{@sender}#{SECRET_EMAIL_SALT}"
      20.times { email_hash = Digest::SHA512.hexdigest(email_hash) }
      self.sender_hash = email_hash
    else
      self.sender_hash = nil
    end
    @sender
  end
  
  attr_reader :recipients, :recipient_emails
  def recipients=(value)
    if value.is_a?(Array)
      @recipient_emails = value.map(&:strip)
      @recipients = value.join(', ')
    else
      @recipients = value.to_s.strip
      @recipient_emails = value.to_s.split(/\s*,\s*/)
    end
    
    @recipients
  end
  
  def requires_captcha_with_message?
    true
  end
  
  def requires_captcha_without_message?
    EntryEmail.count(:conditions => ["created_at > ? AND remote_ip = ?", 1.day.ago, remote_ip]) >= 10
  end
  
  def requires_captcha?
    (message.present? && requires_captcha_with_message?) || requires_captcha_without_message?
  end
  
  private
  
  def sender_email_is_valid
    errors.add(:sender, "'#{@sender}' is invalid") unless email_is_valid?(@sender)
  end
  
  def recipient_emails_are_valid
    @recipient_emails.to_a.each do |email|
      errors.add(:recipients, "'#{email}' is invalid") unless email_is_valid?(email)
    end
  end
  
  def no_more_than_10_recipients
    errors.add(:recipients, "Can only send to 10 recipients") if @recipient_emails && @recipient_emails.count > 10
  end
  
  def calculate_num_recipients
    self.num_recipients = @recipient_emails.try(:count) || 0
  end
  
  def deliver_email
    Mailer.deliver_entry_email(self)
  end
  
  # very basic sanity check...no whitespace in username, very lax host name
  def email_is_valid?(email)
    email =~ /[^@ \t\n\r]+@[a-zA-Z0-9\.-]{3,}$/
  end
end
