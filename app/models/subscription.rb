class Subscription < ApplicationModel
  before_create :generate_token
  after_create :ask_for_confirmation
  
  validates_presence_of :email, :requesting_ip
  
  private
  
  def ask_for_confirmation
    Mailer.send_later :deliver_subscription_confirmation, self
  end
  
  def generate_token
    self.token = SecureRandom.hex(20)
  end
end