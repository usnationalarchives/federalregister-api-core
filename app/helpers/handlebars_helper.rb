module HandlebarsHelper
  def add_template(name, id)
    html = ['<script id="']
    html << id
    html << '-template" type="text/x-handlebars-template">'
    html << File.read( File.join(File.dirname(__FILE__), '..', 'templates', "#{name}.handlebars") )
    html << '</script>'
    html.join('').html_safe
  end
end

