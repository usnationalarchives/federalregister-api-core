Recaptcha.configure do |config|
  config.public_key  = Rails.application.credentials.dig(:google, :recaptcha, :public_key)
  config.private_key = Rails.application.credentials.dig(:google, :recaptcha, :private_key)
end
