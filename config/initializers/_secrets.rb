SECRETS = File.open( File.join(File.dirname(__FILE__), '..', 'secrets.yml') ) { |yf| YAML::load( yf ) }
SECRET_SESSION_KEY = SECRETS['session_key']
SECRET_EMAIL_SALT = SECRETS['email_salt']
SECRET_REG_GOV_API_KEY = SECRETS['data_dot_gov']['api_key']
