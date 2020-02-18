if Rails.env.development?
  BetterErrors.maximum_variable_inspect_size = 1_000
end
