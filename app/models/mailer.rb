class Mailer < ActionMailer::Base
  include SendGrid
  # include RouteBuilder
  helper :entry, :text

  sendgrid_enable :clicktracking, :ganalytics

  def password_reset_instructions(user)
    sendgrid_category "Admin Password Reset"
    sendgrid_disable :ganalytics

    @user = user
    @edit_password_reset_url = edit_admin_password_reset_url(user.perishable_token)

    mail to: user.email,
      subject: "Federal Register Admin Password Reset",
      from: "Federal Register Admin <no-reply@mail.federalregister.gov>",
      sent_on: Time.current
  end

  def daily_import_update_admin_email(date)
    sendgrid_category "Daily Import Update Admin Email"

    recipients = Rails.application.credentials.dig(:app, :mailer, :developer_recipients)
    if Rails.env.production?
      recipients += Rails.application.credentials.dig(:app, :mailer, :core_ofr_recipients)
      recipients += Rails.application.credentials.dig(:app, :mailer, :ofr_daily_import)
    end
    sendgrid_recipients recipients

    sendgrid_ganalytics_options(
      utm_source: 'federalregister.gov',
      utm_medium: 'admin email',
      utm_campaign: 'daily import update'
    )

    @agency_name_presenter = AgencyNameAuditPresenter.new(date)
    @problematic_document_presenter = ProblematicDocumentPresenter.new(date)
    @issue_page_numbering_presenter = IssuePageNumberingPresenter.new(date)

    mail to: "no-reply@mail.federalregister.gov",
      subject: "[FR Admin] Daily Import Update for #{date} (#{Rails.env})",
      from: "Federal Register Admin <no-reply@mail.federalregister.gov>",
      recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
      sent_on: Time.current
  end

  def admin_notification(message)
    sendgrid_category "Admin Notification Email"
    sendgrid_disable :ganalytics

    sendgrid_recipients Rails.application.credentials.dig(:app, :mailer, :developer_recipients)

    @message = message

    mail to: "no-reply@mail.federalregister.gov",
      subject: "[FR Notification] #{Rails.env} -- Urgent Admin Notification",
      from: "Federal Register Admin <no-reply@mail.federalregister.gov>",
      recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
      sent_on: Time.current
  end

  def public_inspection_api_failure(error)
    sendgrid_category "Public Inspection API Failure Email"
    sendgrid_disable :ganalytics

    recipients = Rails.application.credentials.dig(:app, :mailer, :developer_recipients) +
    Rails.application.credentials.dig(:app, :mailer, :core_ofr_recipients) +
    Rails.application.credentials.dig(:app, :mailer, :pil_api_failure)

    sendgrid_recipients recipients

    attachments[File.basename(error.response_path)] = File.read(error.response_path)
    @api_url = "#{Rails.application.secrets[:public_inspection][:api_base_uri]}/eDocs/PIReport/#{Date.current.strftime("%Y%m%d")}"
    @error = error

    mail to: "no-reply@mail.federalregister.gov",
      subject: "[FR Notification] #{Rails.env} -- Unexpected Public Inspection API Results",
      from: "Federal Register Admin <no-reply@mail.federalregister.gov>",
      recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
      sent_on: Time.current
  end

  def ofr_gpo_content_notification(message)
    sendgrid_category "OFR/GPO Notification Email"
    sendgrid_disable :ganalytics

    recipients = Rails.application.credentials.dig(:app, :mailer, :developer_recipients) +
      Rails.application.credentials.dig(:app, :mailer, :core_ofr_recipients) +
      Rails.application.credentials.dig(:app, :mailer, :gpo_content_notification)

    sendgrid_recipients recipients

    @message = message

    mail to:  "no-reply@mail.federalregister.gov",
      subject: "[FederalRegister.gov Notification] #{Rails.env} -- Urgent Content Notification",
      from: "Federal Register Admin <no-reply@mail.federalregister.gov>",
      recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
      sent_on: Time.current
  end

  def pager_duty(message)
    sendgrid_category "Pager Duty Email"
    sendgrid_disable :ganalytics

    sendgrid_recipients Rails.application.credentials.dig(:app, :admin, :pager_duty_email)

    @message = message

    mail to: "no-reply@mail.federalregister.gov",
      subject: "Content has not been imported!",
      from: "Federal Register Admin <no-reply@mail.federalregister.gov>",
      recipients: 'nobody@federalregister.gov', # should use sendgrid_recipients for actual recipient list
      sent_on: Time.current
  end
end
