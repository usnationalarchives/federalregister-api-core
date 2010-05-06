module AdminHelper
  def password_instructions
    content_tag(:p, "Your password must be at least 8 characters long and contain at least one number and one letter.")
  end
end