$(document).ready(function() {
  $('a.rss').live('click', function(){
    generate_dialog();
    $('#rss_modal').jqmShow();
    return false;
  })
  
  function generate_dialog(){
    if ($('#rss_modal').size() == 0) {
      var template = [
        '<div id="rss_modal">',
        '  <a href="#" class="jqmClose">Close</a>',
        '  <h3>Select a feed</h3>',
        '  <p>Select from the following feeds:</p>',
        '  <ul>',
        '  <% elements.each(function(){ %>',
        '    <li><a href="<%= this.href %>"><%= this.title %></a></li>',
        '  <% }); %>',
        '  </ul>',
        '</div>'
      ].join("\n")
    
      var elements = $('link[type="application/rss+xml"]').map(function(){
        var elem = $(this);
        return {
          title : elem.attr('title'),
          href  : elem.attr('href')
        }
      });
      $('body').append(tmpl(template, {elements: elements}));
      $('#rss_modal').jqm({modal: true, toTop: true});
    }
  }
});