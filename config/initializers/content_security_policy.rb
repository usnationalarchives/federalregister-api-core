# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy_report_only = Settings.app.csp.report_only

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data, :report_sample
  policy.object_src  :none

  script_srcs = [
    :self,
    :https,
    :report_sample,
  ]

  policy.script_src  *script_srcs
  policy.style_src   :self, :https, :report_sample, :unsafe_inline

  #   # Specify URI for violation reports
  if ['production', 'staging'].include?(Rails.env)
    # Increment version on each change to this file
    csp_version = 2

    policy.report_uri -> {
      api_key = Rails.application.credentials.dig(:honeybadger, :csp_api_key)
      context = {context: try(:honeybadger_context) || {}}
      context[:context][:csp_version] = csp_version
      context_args = context.to_query
      "https://api.honeybadger.io/v1/browser/csp?api_key=#{api_key}&env=#{Rails.env}&report_only=#{Settings.app.csp.report_only}&#{context_args}"
    }
  end
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
