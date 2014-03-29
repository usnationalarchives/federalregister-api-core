secrets = File.open( File.join(File.dirname(__FILE__), '..', 'secrets.yml') ) { |yf| YAML::load( yf ) }
SECRET_SESSION_KEY = secrets['session_key']
SECRET_EMAIL_SALT = secrets['email_salt']
SECRET_REG_GOV_API_KEY = secrets['data_dot_gov']['api_key']
