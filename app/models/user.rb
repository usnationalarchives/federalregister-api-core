class User < ApplicationModel
  acts_as_authentic do |c|
    c.validate_password_field = false
    c.logged_in_timeout = 30.minutes unless RAILS_ENV == 'development'
  end
  
  model_stamper
  stampable
  
  attr_accessor :current_password
  attr_protected :password
  
  validates_presence_of :first_name, :last_name
  
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 8, :allow_nil => true
  validates_format_of :password, :with => /[a-z]/i, :allow_nil => true, :message => "must include a letter"
  validates_format_of :password, :with => /[0-9]/, :allow_nil => true, :message => "must include a number"
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Mailer.deliver_password_reset_instructions(self)
  end
  
end
