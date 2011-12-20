function closeOnEscape(hash) {
  $(window).one('keyup', function(event) {
    if( event.keyCode === '27' ){
      hash.w.jqmHide();
    }
  });
}
var modalOpen = function(hash) {
  closeOnEscape(hash);
  hash.w.show();
};


$(document).ready(function () {
    function generate_dialog() {
        if ($('#modal').size() === 0) {
            var subscription_modal_template;
            if ( $("#subscription-modal-template").length > 0 ) {
              subscription_modal_template = Handlebars.compile( $("#subscription-modal-template").html() );
            }

            var elements = $('link[type="application/rss+xml"]').map(function () {
              var elem = $(this);
              var feed = {
                title: elem.attr('title'),
                href: elem.attr('href'),
                escaped_href: escape(elem.attr('href'))
              };
              if(elem.attr('data-search-conditions')) {
                feed.subscription_action = "/subscriptions?" + $.param({'subscription' : {'search_conditions' : $.parseJSON(elem.attr('data-search-conditions'))}});
              }

              if( elem.data('public-inspection-subscription-supported') !== undefined ) {
                feed.public_inspection_subscription_supported = elem.data('public-inspection-subscription-supported');
              }

              if( elem.data('default-search-type') === "PublicInspectionDocument" ) { 
                feed.default_to_public_inspection = true; 
              } else {
                feed.default_to_entry = true;
              }

              return feed;
            });

            $('body').append( subscription_modal_template({elements: elements}) );

            $('#modal form').submit(function() {
                var form = $(this);
                form.attr('action', form.attr('action') + '&' + escape('subscription[email]') + '=' + escape(form.find('input[name="subscription[email]"]').val()) + '&' + escape('subscription[search_type]') + '=' + escape(form.find('input[name="subscription[search_type]"]:checked').val()) );
            });

            $('#modal').jqm({
                modal: true,
                toTop: true,
                onShow: modalOpen
            });            
        }
    }

    $('a.rss, a.subscription, a.subscription_action').live('click',
      function () {
        generate_dialog();
        $('#modal input[placeholder]').textPlaceholder();
        $('#modal').centerScreen().jqmShow();
        return false;
      }
    );
});
