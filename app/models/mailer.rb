class Mailer < ActionMailer::Base
  def password_reset_instructions(user)
    subject    "FR2 Admin Password Reset"
    from       "FR2 Admin <info@criticaljuncture.org>"
    recipients user.email
    sent_on    Time.now
    body       :user => user, :edit_password_reset_url => edit_admin_password_reset_url(user.perishable_token)
  end
  
  def subscription_confirmation(subscription)
    subject    "[FR] #{subscription.title}"
    from       "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
    recipients subscription.email
    sent_on    Time.now
    body       :subscription => subscription
  end
end
