module Rails3UpgradeSpecHelperMethods
  def h(input)
    ERB::Util.html_escape(input)
  end

  # This method was deprecated in later versions of rspec (rspec 2ish).  Bringing the code into Rails 3.2 from here: https://www.rubydoc.info/gems/rspec-rails/1.3.4/Spec%2FRails%2FExample%2FHelperExampleGroup:eval_erb
  def eval_erb(text)
    erb_args = [text]
    if helper.respond_to?(:output_buffer)
      erb_args += [nil, nil, '@output_buffer']
    end

    helper.instance_eval do
      ERB.new(*erb_args).result(binding)
    end
  end

end
