class Mailer < ActionMailer::Base
  def password_reset_instructions(user)
    subject    "FR2 Admin Password Reset"
    from       "FR2 Admin <info@criticaljuncture.org>"
    recipients user.email
    sent_on    Time.current
    body       :user => user, :edit_password_reset_url => edit_admin_password_reset_url(user.perishable_token)
  end
  
  def subscription_confirmation(subscription)
    subject    "[FR] #{subscription.mailing_list.title}"
    from       "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
    recipients subscription.email
    sent_on    Time.current
    body       :subscription => subscription
  end
  
  def mailing_list(mailing_list, results, subscriptions)
    subject "[FR] #{mailing_list}"
    from       "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
    recipients subscriptions.map(&:email)
    custom_variables :token => subscriptions.map(&:token)
    sent_on    Time.current
    body       :title => mailing_list.title, :results => results
  end
end
