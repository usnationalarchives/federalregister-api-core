$(document).ready(function() {
  $('a.rss').live('click', function(){
    generate_dialog();
    $('#modal').centerScreen().jqmShow(); 
    return false;
  })
  
  function generate_dialog(){
    if ($('#modal').size() == 0) {
      var template = [
        '<div id="modal">',
        '  <a href="#" class="jqmClose close">Close</a>',
        '  <h3 class="title_bar">Select a feed</h3>',
        '  <p>Select from the following feeds:</p>',
        '  <ul class="bullets">',
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
      $('#modal').jqm({modal: true, toTop: true});
    }
  }
});