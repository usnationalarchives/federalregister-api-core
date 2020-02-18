Recaptcha.configure do |config|
  config.public_key  = Rails.application.secrets[:api_keys][:recaptcha_public]
  config.private_key = Rails.application.secrets[:api_keys][:recaptcha_private]
end
