# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_trifecta_session',
  :secret      => '098d7b5d23e8fafe7e403b5b7a21175f80ae370d9549b2a759e7013dd200a21966e781a2b94349f28ea752aaabf58da13a4cc99ee6237a80cc548b463a9abfec'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
