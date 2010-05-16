=begin Schema Information

 Table name: users

  id                  :integer(4)      not null, primary key
  email               :string(255)     not null
  crypted_password    :string(255)
  password_salt       :string(255)
  persistence_token   :string(255)     not null
  single_access_token :string(255)     not null
  perishable_token    :string(255)     not null
  login_count         :integer(4)      default(0), not null
  failed_login_count  :integer(4)      default(0), not null
  last_request_at     :datetime
  current_login_at    :datetime
  last_login_at       :datetime
  current_login_ip    :string(255)
  last_login_ip       :string(255)
  created_at          :datetime
  updated_at          :datetime
  creator_id          :integer(4)
  updater_id          :integer(4)
  first_name          :string(255)
  last_name           :string(255)
  active              :boolean(1)      default(TRUE)

=end Schema Information

class User < ApplicationModel
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.validate_password_field = false
    c.logged_in_timeout = RAILS_ENV == 'development' ? 8.hours : 30.minutes
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
  
end
