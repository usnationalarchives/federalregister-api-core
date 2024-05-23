module AdminHelper
  def password_instructions
    content_tag(:p, "Your password must be at least 8 characters long and contain at least one number and one letter.")
  end

  def rating_scale_explanation
    <<-TXT
      0 – No useful information
      1 – Some useful information
      2 – Significant useful information
      3 – Essential useful information
      4 – Critical useful information
    TXT
  end

end
