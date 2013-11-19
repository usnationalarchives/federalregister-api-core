class Mailer < ActionMailer::Base
  include SendGrid
  # include RouteBuilder
  helper :entry, :text
  
  sendgrid_enable :opentracking, :clicktracking, :ganalytics
  
  def password_reset_instructions(user)
    sendgrid_category "Admin Password Reset"
    
    subject    "FR2 Admin Password Reset"
    from       "FR2 Admin <info@criticaljuncture.org>"
    recipients user.email
    sent_on    Time.current
    body       :user => user, :edit_password_reset_url => edit_admin_password_reset_url(user.perishable_token)
  end
  
  def subscription_confirmation(subscription)
    sendgrid_category "Subscription Confirmation"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription confirmation'
    
    subject    "[FR] #{subscription.mailing_list.title}"
    from       "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
    recipients subscription.email
    sent_on    Time.current
    body       :subscription => subscription
  end

  def unsubscribe_notice(subscription)
    sendgrid_category "Subscription Unsubscribe"
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription unsubscribe'
    
    subject "[FR] #{subscription.mailing_list.title}"
    from       "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
    recipients subscription.email
    sent_on    Time.current
    body       :subscription => subscription
  end
  
  def public_inspection_document_mailing_list(mailing_list, results, subscriptions)
    sendgrid_category "PI Subscription"
    sendgrid_recipients subscriptions.map(&:email)
    sendgrid_substitute "(((token)))", subscriptions.map(&:token)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'pi subscription mailing list'
    
    toc = TableOfContentsPresenter.new(results)
    
    subject "[FR] #{mailing_list.title}"
    from       "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
    recipients 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    sent_on    Time.current
    body       :mailing_list => mailing_list, :results => results, :agencies => toc.agencies, :entries_without_agencies => toc.entries_without_agencies
  end

  def entry_mailing_list(mailing_list, results, subscriptions)
    sendgrid_category "Subscription"
    sendgrid_recipients subscriptions.map(&:email)
    sendgrid_substitute "(((token)))", subscriptions.map(&:token)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'subscription mailing list'
    
    toc = TableOfContentsPresenter.new(results)
    
    subject "[FR] #{mailing_list.title}"
    from       "Federal Register Subscriptions <subscriptions@mail.federalregister.gov>"
    recipients 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    sent_on    Time.current
    body       :mailing_list => mailing_list, :results => results, :agencies => toc.agencies, :entries_without_agencies => toc.entries_without_agencies
  end
  
  def entry_email(entry_email)
    sendgrid_category "Email a Friend"
    sendgrid_recipients entry_email.all_recipient_emails
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'email a friend'
    
    subject "[FR] #{entry_email.entry.title}"
    from entry_email.sender
    recipients 'nobody@mail.federalregister.gov' # should use sendgrid_recipients for actual recipient list
    sent_on Time.current
    body :entry => entry_email.entry, :sender => entry_email.sender, :message => entry_email.message
  end

  def agency_name_mapping_admin_email(date)
    sendgrid_category "Agency Name Mapping Admin Email"
    sendgrid_recipients %w(awoo@gpo.gov mvincent@gpo.gov mscott@gpo.gov kgreen@gpo.gov aotovo@gpo.gov)
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'admin email', :utm_campaign => 'daily agency name mapping'

    remappings = AgencyNameAuditPresenter.new(date)

    subject "[FR Admin] Daily Agency Name Mapping for #{date}"
    from       "Federal Register Admin <no-reply@mail.federalregister.gov>"
    recipients 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    sent_on    Time.current
    body       :remappings => remappings, :date => date
  end


end
