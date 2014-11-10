Recaptcha.configure do |config|
  config.public_key  = SECRETS['api_keys']['recaptcha_public']
  config.private_key = SECRETS['api_keys']['recaptcha_private']
end
