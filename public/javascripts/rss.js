$(document).ready(function () {
    $('a.rss, a.subscription').live('click',
    function () {
        generate_dialog();
        $('#modal input[placeholder]').textPlaceholder();
        $('#modal').centerScreen().jqmShow();
        return false;
    });

    function generate_dialog() {
        if ($('#modal').size() == 0) {
            var template = [
              '<div id="modal">',
              '  <a href="#" class="jqmClose">Close</a>',
              '  <h3 class="title_bar">Select a feed</h3>',
              '  <p>Select from the following feeds:</p>',
              '  <ul class="bullets">',
              '  <% elements.each(function(){ %>',
              '   <li>',
              '     <h4><a href="<%= this.href %>" title="Add to your Feed Reader"><%= this.title %></a></h4>',
              '      <ul class="horizontal">',
              '         <li><a href="http://add.my.yahoo.com/rss?url=<%= escape(this.href)  %>" title="Add feed to Yahoo"><img src="http://us.i1.yimg.com/us.yimg.com/i/us/my/addtomyyahoo4.gif" /></a></li>',
              '         <li><a href="http://fusion.google.com/add?feedurl=<%= escape(this.href) %>" title="Add feed to Google"><img src="http://buttons.googlesyndication.com/fusion/add.gif" /></a></li>',
              '         <li><a href="http://www.netvibes.com/subscribe.php?url=<%= escape(this.href) %>" title="Add feed to Netvibes"><img src="http://www.netvibes.com/img/add2netvibes.gif" /></a></li>',
              '         <% if(this.subscription_action) { %>',
              '         <li>',
              '           <form action="<%= this.subscription_action %>" method="post">',
              '             <label>Via E-Mail: </label>',
              '             <input type="email" name="subscription[email]" placeholder="E-Mail Address">',
              '             <input type="submit" value="Subscribe">',
              '           </form>',
              '         </li>',
              '         <% } %>',              
              '     </ul>',
              '   </li>',
              '  <% }); %>',
              '  </ul>',
              '</div>'
            ].join("\n");

            var elements = $('link[type="application/rss+xml"]').map(function () {
                var elem = $(this);
                var feed = {
                  title: elem.attr('title'),
                  href: elem.attr('href')
                };
                if(elem.attr('data-search-conditions')) {
                  feed.subscription_action = "/subscriptions?" + $.param({'subscription' : {'search_conditions' : $.parseJSON(elem.attr('data-search-conditions'))}})
                }
                
                return feed;
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