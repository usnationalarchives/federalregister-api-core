class User < ApplicationModel
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.validate_password_field = false
    c.logged_in_timeout = RAILS_ENV == 'development' ? 8.hours : 2.hours
  end

  model_stamper
  stampable

  attr_accessor :current_password
  attr_protected :password

  validates_presence_of :first_name, :last_name

  validates_confirmation_of :password
  validates_length_of :password, :minimum => 6, :allow_nil => true
  validates_format_of :password, :with => /[a-z]/i, :allow_nil => true, :message => "must include a letter"
  validates_format_of :password, :with => /[0-9]/, :allow_nil => true, :message => "must include a number"

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Mailer.deliver_password_reset_instructions(self)
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
