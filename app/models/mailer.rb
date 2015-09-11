class Mailer < ActionMailer::Base
  include SendGrid
  # include RouteBuilder
  helper :entry, :text

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  FR_DEVELOPER_ADMINS = %w(bob@criticaljuncture.org andrew@criticaljuncture.org rich@criticaljuncture.org brandon@criticaljuncture.org)

  def password_reset_instructions(user)
    sendgrid_category "Admin Password Reset"

    subject    "FR2 Admin Password Reset"
    from       "FR2 Admin <info@criticaljuncture.org>"
    recipients user.email
    sent_on    Time.current
    body       :user => user, :edit_password_reset_url => edit_admin_password_reset_url(user.perishable_token)
  end

  def entry_email(entry_email)
    sendgrid_category "Email a Friend"
    sendgrid_recipients entry_email.all_recipient_emails
    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'email', :utm_campaign => 'email a friend'

    subject "[FR] #{entry_email.sender} has sent you '#{entry_email.entry.title}'"
    from entry_email.sender.split('@').first
    recipients 'email-a-friend@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    reply_to entry_email.sender
    sent_on Time.current
    body :entry => entry_email.entry, :sender => entry_email.sender, :message => entry_email.message
  end

  def daily_import_update_admin_email(date)
    sendgrid_category "Daily Import Update Admin Email"

    recipients = FR_DEVELOPER_ADMINS
    if RAILS_ENV == 'production'
      recipients += %w(
        awoo@gpo.gov mvincent@gpo.gov mscott@gpo.gov
        kgreen@gpo.gov aotovo@gpo.gov tellis@gpo.gov
        jhemphill@gpo.gov jmarlor@gpo.gov eswidal@gpo.gov
        ofrtechgroup@gpo.gov
      )
    end
    sendgrid_recipients recipients

    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'admin email', :utm_campaign => 'daily agency name mapping'

    agency_name_presenter = AgencyNameAuditPresenter.new(date)
    problematic_document_presenter = ProblematicDocumentPresenter.new(date)

    subject "[FR Admin] Daily Import Update for #{date}"
    from       "Federal Register Admin <no-reply@mail.federalregister.gov>"
    recipients 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    sent_on    Time.current
    body       :agency_name_presenter => agency_name_presenter, :date => date, :problematic_document_presenter => problematic_document_presenter
  end

  def admin_notification(message)
    sendgrid_category "Admin Notification Email"

    sendgrid_recipients FR_DEVELOPER_ADMINS

    subject "[FR Notification] Urgent Admin Notification"
    from       "Federal Register Admin <no-reply@mail.federalregister.gov>"
    recipients 'nobody@federalregister.gov' # should use sendgrid_recipients for actual recipient list
    sent_on    Time.current
    body       :message => message
  end
end
