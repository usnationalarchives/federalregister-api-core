module UnimplementedHelper
  def link_to_unimplemented( link_text, html_options = {} )
    html_options['class'] = 'unimplemented ' + (html_options['class'] || '')
    link_to_function( link_text, 'unimplemented()', html_options)
  end
  
  def display_unimplemented(text)
    "<span class='unimplemented'>#{text}</span>"
  end
end