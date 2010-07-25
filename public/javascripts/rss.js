$(document).ready(function () {
    $('a.rss').live('click',
    function () {
        generate_dialog();
        $('#modal').centerScreen().jqmShow();
        return false;
    });

    function generate_dialog() {
        if ($('#modal').size() == 0) {
            var template = [
              '<div id="modal">',
              '  <a href="#" class="jqmClose close">Close</a>',
              '  <h3 class="title_bar">Select a feed</h3>',
              '  <p>Select from the following feeds:</p>',
              '  <ul class="bullets">',
              '  <% elements.each(function(){ %>',
              '   <li>',
              '     <h4><a href="<%= this.href %>" title="Add to your Feed Reader"><%= this.title %></a></h4>',
              '      <ul class="horizontal">',
              '         <li><a href="http://add.my.yahoo.com/rss?url=<%= escape(this.href)  %>" title="Add feed to Yahoo"><img src="http://us.i1.yimg.com/us.yimg.com/i/us/my/addtomyyahoo4.gif" /></a><li>',
              '         <li><a href="http://fusion.google.com/add?feedurl=<%= escape(this.href) %>" title="Add feed to Google"><img src="http://buttons.googlesyndication.com/fusion/add.gif" /></a><li>',
              '         <li><a href="http://www.netvibes.com/subscribe.php?url=<%= escape(this.href) %>" title="Add feed to Netvibes"><img src="http://www.netvibes.com/img/add2netvibes.gif" /></a><li>',
              '     </ul>',
              '   </li>',
              '  <% }); %>',
              '  </ul>',
              '</div>'
            ].join("\n");

            var elements = $('link[type="application/rss+xml"]').map(function () {
                var elem = $(this);
                return {
                    title: elem.attr('title'),
                    href: elem.attr('href')
                };
            });
            $('body').append(tmpl(template, {
                elements: elements
            }));
            $('#modal').jqm({
                modal: true,
                toTop: true
            });
        }
    }
});