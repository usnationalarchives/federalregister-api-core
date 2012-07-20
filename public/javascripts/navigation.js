function setup_preview_scroller( text_wrapper ) {
  var text_bg = text_wrapper.siblings('div.bg').first();
  text_bg.css('height', text_wrapper.height());

  var attribution    = text_wrapper.siblings('div.attribution').first();
  var attribution_bg = text_wrapper.siblings('div.bg.attribution').first();
  attribution_bg.css('width', attribution.width()).css('height', attribution.height());
}

$(document).ready( function() {
  $('#navigation .subnav').bind('mouseenter', function() {
    $(this).closest('.dropdown').find('a.top_nav').addClass('hover');
  });
  $('#navigation .subnav').bind('mouseleave', function() {
    $(this).closest('.dropdown').find('a.top_nav').removeClass('hover');
    $('.ui-autocomplete.ui-menu').hide();
  });

  $('#navigation .nav_sections a.sections').bind('mouseenter', function() {
    nav_sections = $(this).closest('.nav_sections');
    nav_sections.find('.left_column li#money a').addClass('hover');
    preview = nav_sections.find('.right_column li#money-preview');
    preview.show();
    setup_preview_scroller( preview.find('.text_wrapper') );
   });

  $('#navigation .nav_browse a.browse').bind('mouseenter', function() {
    nav_sections = $(this).closest('.nav_browse');
    nav_sections.find('.left_column li#agencies-browse a').addClass('hover');
    preview = nav_sections.find('.right_column li#agencies-browse-preview');
    preview.show();
   });

  $('#navigation .subnav .left_column li').bind('mouseenter', function() {
    $('#navigation .subnav .right_column li.preview').hide();
    preview = $('#navigation .subnav .right_column').find('#' + $(this).attr('id') + '-preview');
    preview.show();
    setup_preview_scroller( preview.find('.text_wrapper') );
  });

  $('#navigation .subnav .left_column li').bind('mouseleave', function() {
    $(this).find('a').removeClass('hover');
    $('.ui-autocomplete.ui-menu').hide();
  });


  $("input[data-autocomplete]#agency-search").each(function(){
        var input = $(this);
        input.autocomplete({
        minLength: 3,
        source: function( request, response ){
          var elem = input;
          $.ajax({
            url: "/agencies/search?term=" + request.term,
            success: function(data){
              $(elem).removeClass("loading");
              response( 
                $.map( data, function( item ) {
                  return {
                    label: item.name,
                    value: item.name,
                    id: item.id,
                    url: item.url
                  };
                })
              );
              $('.ui-autocomplete.ui-menu').css({'padding': '5px 0px', 'box-shadow': '#888 0 3px 5px'});
              $('.ui-autocomplete.ui-menu a').css({'padding': '2px 10px', 'font-size': '14px', 'font-weight': 'bold'});
            } // end success
          }); // end ajax
        },
        select: function( event, ui ) {
          window.location.href = ui.item.url;
          $(this).data('clear-value', 1);
        },
        close: function() {
          var input = $(this);
          if (input.data('clear-value')) {
             input.val('');
             input.data('clear-value',0);
          }
        },
        search: function( event, ui) {
          $(this).addClass("loading");
        }
      });
    });

    $("input[data-autocomplete]#topic-search").each(function(){
      var input = $(this);
      input.autocomplete({
      minLength: 3,
      source: function( request, response ){
        var elem = input;
        $.ajax({
          url: "/topics/search?term=" + request.term,
          success: function(data){
            $(elem).removeClass("loading");
            response( 
              $.map( data, function( item ) {
                return {
                  label: item.name,
                  value: item.name,
                  id: item.id,
                  url: item.url
                };
              })
            );
            $('.ui-autocomplete.ui-menu').css({'padding': '5px 0px', 'box-shadow': '#888 0 3px 5px'});
            $('.ui-autocomplete.ui-menu a').css({'padding': '2px 10px', 'font-size': '14px', 'font-weight': 'bold'});
          } // end success
        }); // end ajax
      },
      select: function( event, ui ) {
        window.location.href = ui.item.url;
        $(this).data('clear-value', 1);
      },
      close: function() {
        var input = $(this);
        if (input.data('clear-value')) {
           input.val('');
           input.data('clear-value',0);
        }
      },
      search: function( event, ui) {
        $(this).addClass("loading");
      }
    });
  });
});
