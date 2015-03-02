# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Intranet_session',
  :secret      => '5368851174b5e1f452c1fa94f0f5aaf0c45660a5879ffde78f2786dc7bbac175a0ceb40cc45d2631e36d3538bfc0e2453b94977fa7082432ed209851be3bade6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
