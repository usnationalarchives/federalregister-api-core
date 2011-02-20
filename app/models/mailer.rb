class Mailer < ActionMailer::Base
  helper :entry, :text
  
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
  
  def mailing_list(mailing_list, results, subscription)
    subject "[FR] #{mailing_list.title}"
    from       "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
    recipients subscription.email
    sent_on    Time.current
    body       :mailing_list => mailing_list, :results => results, :subscription => subscription
  end
  
  def entry_email(entry_email)
    subject "[FR] #{entry_email.entry.title}"
    from entry_email.sender
    recipients entry_email.recipients
    sent_on Time.current
    body :entry => entry_email.entry, :sender => entry_email.sender
  end
end
