Recaptcha.configure do |config|
  config.public_key  = ENV['recaptcha_public_api_key']
  config.private_key = ENV['recaptcha_private_api_key']
end
