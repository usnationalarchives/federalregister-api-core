class AuthConstraint

  def self.matches?(request)
    return false unless request.cookie_jar['user_credentials'].present?
    user = User.find_by_persistence_token(request.cookie_jar['user_credentials'].split(':')[0])
    user
  end

end
