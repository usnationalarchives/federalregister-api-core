class Mailer < ActionMailer::Base
  include SendGrid
  # include RouteBuilder
  helper :entry, :text

  sendgrid_enable :opentracking, :clicktracking, :ganalytics

  FR_DEVELOPER_ADMINS = %w(bob@criticaljuncture.org andrew@criticaljuncture.org rich@criticaljuncture.org brandon@criticaljuncture.org)

  def password_reset_instructions(user)
    sendgrid_category "Admin Password Reset"

    @user = user
    @edit_password_reset_url = edit_admin_password_reset_url(user.perishable_token)

    mail  to:         user.email,
          subject:    "Federal Register Admin Password Reset",
          from:       "Federal Register Admin <no-reply@mail.federalregister.gov>",
          sent_on:    Time.current
  end

  def daily_import_update_admin_email(date)
    sendgrid_category "Daily Import Update Admin Email"

    recipients = FR_DEVELOPER_ADMINS
    if Rails.env.production?
      recipients += %w(
        apokres@gpo.gov mvincent@gpo.gov mscott@gpo.gov sfrattini@gpo.gov
        kgreen@gpo.gov aotovo@gpo.gov tellis@gpo.gov
        jhemphill@gpo.gov jmarlor@gpo.gov eswidal@gpo.gov
        ofrtechgroup@gpo.gov jhmartinez@gpo.gov jfrankovic@gpo.gov
        dperrin@gpo.gov tellis@gpo.gov dzero@gpo.gov dbarfield@gpo.gov
        khorska@gpo.gov katerina.horska@nara.gov
      )
    end
    sendgrid_recipients recipients

    sendgrid_ganalytics_options :utm_source => 'federalregister.gov', :utm_medium => 'admin email', :utm_campaign => 'daily agency name mapping'

    @agency_name_presenter = AgencyNameAuditPresenter.new(date)
    @problematic_document_presenter = ProblematicDocumentPresenter.new(date)
    @issue_page_numbering_presenter = IssuePageNumberingPresenter.new(date)

    mail to:         recipients,
         subject:    "[FR Admin] Daily Import Update for #{date} (#{Rails.env})",
         from:       "Federal Register Admin <no-reply@mail.federalregister.gov>",
         recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
         sent_on:    Time.current
  end

  def admin_notification(message)
    sendgrid_category "Admin Notification Email"

    @message = message

    mail to:         FR_DEVELOPER_ADMINS,
         subject:    "[FR Notification] #{Rails.env} -- Urgent Admin Notification",
         from:       "Federal Register Admin <no-reply@mail.federalregister.gov>",
         recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
         sent_on:    Time.current
  end

  def public_inspection_api_failure(error)
    @error = error
    sendgrid_category "Admin Notification Email"

    attachments[File.basename(error.response_path)] = File.read(error.response_path)
    @api_url = "#{Rails.application.secrets[:public_inspection][:api_base_uri]}/eDocs/PIReport/#{Date.current.strftime("%Y%m%d")}"

    mail to:         Settings.public_inspection.failure_notification_recipients,
         subject:    "[FR Notification] #{Rails.env} -- Unexpected Public Inspection API Results",
         from:       "Federal Register Admin <no-reply@mail.federalregister.gov>",
         recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
         sent_on:    Time.current
  end

  def ofr_gpo_content_notification(message)
    sendgrid_category "OFR/GPO Notification Email"

    recipients = FR_DEVELOPER_ADMINS
    if Rails.env.production?
      recipients += %w(
        govinfo-support@gpo.gov
        ofrtechgroup@gpo.gov
        jhmartinez@gpo.gov
        mvincent@gpo.gov
        sfrattini@gpo.gov
        mscott@gpo.gov
        jmarlor@gpo.gov
        ktilliman@gpo.gov
        khorska@gpo.gov
      )
    end
    sendgrid_recipients recipients

    sendgrid_disable :ganalytics

    @message = message

    mail to:         recipients,
         subject:    "[FederalRegister.gov Notification] #{Rails.env} -- Urgent Content Notification",
         from:       "Federal Register Admin <no-reply@mail.federalregister.gov>",
         recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
         sent_on:    Time.current
  end

  def pager_duty(message)
    sendgrid_category "Pager Duty Email"

    @message = message

    mail to:         ENV['PAGER_DUTY_EMAIL'],
         subject:    "Content has not been imported!",
         from:       "Federal Register Admin <no-reply@mail.federalregister.gov>",
         recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
         sent_on:    Time.current
  end
end
