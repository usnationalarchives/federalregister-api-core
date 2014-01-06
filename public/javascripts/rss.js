
$(document).ready(function () {
    function generate_dialog() {
        if ($('#modal').size() === 0) {
            var subscription_modal_template;
            if ( $("#subscription-modal-template").length > 0 ) {
              subscription_modal_template = Handlebars.compile( $("#subscription-modal-template").html() );
            }

            var elements = $.map( $('link.subscription_feed'), function(el) {
              var elem = $(el);
              var feed = {
                title: elem.attr('title'),
                href: elem.attr('href'),
                escaped_href: encodeURIComponent(elem.attr('href'))
              };
              if(elem.attr('data-search-conditions')) {
                feed.subscription_action = "/my/subscriptions?" + $.param({'subscription' : {'search_conditions' : $.parseJSON(elem.attr('data-search-conditions'))}});
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

            $('body').append( subscription_modal_template({elements: elements, email_address: user_email_address}) );

            $('#modal form').submit(function() {
                var form = $(this);
                form.attr('action', form.attr('action') + '&' + encodeURIComponent('subscription[email]') + '=' + encodeURIComponent(form.find('input[name="subscription[email]"]').val()) + '&' + encodeURIComponent('subscription[search_type]') + '=' + encodeURIComponent(form.find('input[name="subscription[search_type]"]:checked').val()) );
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

        $('#modal .tip_under').tipsy({gravity:'north'});

        /* add email helper for validation and suggestions on blur */
        var email_helper = new EmailHelper();
        $('#modal form.subscription').on('input onpropertychange', '#subscription_email', function() {
            var $input = $(this);

            clearTimeout($input.data('timeout'));

            if( !email_helper.initialized ) {
              email_helper.initialize($input);
            }

            email_helper.reset_help_text();

            $input.data('timeout', setTimeout(function(){
              email_helper.validate_or_suggest();
            }, 500));
        });

        /* add ability to use the suggested correction */
        $('form').on('click', '.email_suggestion .link', function() {
          email_helper.use_suggestion( $(this) );
        });

        return false;
      }
    );
});
