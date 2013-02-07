# Disable XML and JSON input parsing
#   to prevent typecasting security vulnerability
#   https://groups.google.com/forum/#!topic/rubyonrails-security/ZOdH5GH5jCU/discussion
ActionController::Base.param_parsers.delete(Mime::XML) 
ActionController::Base.param_parsers.delete(Mime::JSON) 