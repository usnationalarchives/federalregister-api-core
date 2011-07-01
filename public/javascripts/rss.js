$(document).ready(function () {
    $('a.rss, a.subscription, a.subscription_action').live('click',
    function () {
        generate_dialog();
        $('#modal input[placeholder]').textPlaceholder();
        $('#modal').centerScreen().jqmShow();
        return false;
    });

    function generate_dialog() {
        if ($('#modal').size() == 0) {
            var template = [
              '<div id="modal" class="subscribe">',
              '  <a href="#" class="jqmClose">Close</a>',
              '  <h3>Select a feed</h3>',
              '  <ul>',
              '  <% elements.each(function(){ %>',
              '   <li>',
              '     <h4><%= this.title %></h4>',
              '      <ul class="horizontal icons">',
              '         <li class="header"><h5>Via RSS:</h5> </li>',
              '         <li class="google"><a href="http://fusion.google.com/add?feedurl=<%= escape(this.href) %>" title="Add feed to Google">Google Reader</a></li>',
              '         <li class="yahoo"><a href="http://add.my.yahoo.com/rss?url=<%= escape(this.href)  %>" title="Add feed to Yahoo">My Yahoo</a></li>',
              '         <li class="rss_link"><a href="<%= this.href %>" title="RSS 2.0 Link">RSS 2.0 Link</a></li>',
              '         <% if(this.subscription_action) { %>',
              '         <li class="email">',
              '           <h5>Via Email:</h5>',
              '           <form action="<%= this.subscription_action %>" method="post">',
              '             <label>Via E-Mail: </label>',
              '             <input type="email" name="subscription[email]" placeholder="Subscribe via E-Mail" class="address">',
              '             <input type="submit" value="Subscribe" class="subscribe">',
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

            $('#modal form').submit(function() {
                var form = $(this);
                form.attr('action', form.attr('action') + '&' + escape('subscription[email]') + '=' + escape(form.find('input[name="subscription[email]"]').val()));
            });

            $('#modal').jqm({
                modal: true,
                toTop: true,
                onShow: function(hash){
                  $(window).one('keypress', function(event) {
                    if( event.keyCode == '27' ){
                      hash.w.jqmHide();
                    }
                  });
                  hash.w.show();
                }
            });            
        }
    }
});
