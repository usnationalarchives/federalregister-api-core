module Rails3UpgradeSpecHelperMethods
  def h(input)
    ERB::Util.html_escape(input)
  end

  # This method was deprecated in later versions of rspec (rspec 2ish).  Bringing the code into Rails 3.2 from here: https://www.rubydoc.info/gems/rspec-rails/1.3.4/Spec%2FRails%2FExample%2FHelperExampleGroup:eval_erb
  def eval_erb(text)
    if helper.respond_to?(:output_buffer)
      options = {trim_mode: nil, eoutvar: '@output_buffer'}
    else
      options = {}
    end

    helper.instance_eval do
      ERB.new(text, **options).result(binding)
    end
  end

end
