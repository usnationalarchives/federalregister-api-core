function setup_preview_scroller( text_wrapper ) {
  var text_bg = text_wrapper.siblings('div.bg').first();
  text_bg.css('height', text_wrapper.height());

  var attribution    = text_wrapper.siblings('div.attribution').first();
  var attribution_bg = text_wrapper.siblings('div.bg.attribution').first();
  attribution_bg.css('width', attribution.width()).css('height', attribution.height());
}

function setup_previewable_nav(el) {
    /* hide all other sections and show the first */
    var nav_sections = el.closest('.dropdown');
    nav_sections.find('.left_column li').children('a').removeClass('hover');
    nav_sections.find('.left_column li').first().find('a').addClass('hover');
    nav_sections.find('.right_column').children('li').hide();
    var preview = nav_sections.find('.right_column li').first();
    preview.show();

    /* ensure that sections get setup properly */
    if( el.hasClass('sections') ) { 
      setup_preview_scroller( preview.find('.text_wrapper') );
    }
}

$(document).ready( function() {
  var navigation_timeout = null;

  $('#navigation .dropdown').bind('mouseenter', function() {
    /* ensure other menus close - this covers odd edge cases that
     * bypass mouseleave (opening another tab, switching apps, etc). */
    $(this).siblings().trigger('mouseleave');

    $(this).find('a.top_nav').addClass('hover');
    $(this).find('.subnav').show();
  });

  $('#navigation .dropdown').bind('mouseleave', function() {
    $(this).find('.subnav').hide();
    $(this).find('a.top_nav').removeClass('hover');
  });

  $('#navigation .subnav').bind('mouseenter', function() {
    $(this).closest('.dropdown').find('a.top_nav').addClass('hover');
  });
  
  $('#navigation .subnav').bind('mouseleave', function() {
    $(this).closest('.dropdown').find('a.top_nav').removeClass('hover');
    $(this).hide();
  });

  //$('.ui-autocomplete').live('mouseenter', function() {
    //current_open_menu.closest('.dropdown').find('a.top_nav').addClass('hover');
    //current_open_menu.show();
    //$(this).show();
  //});
  //$('.ui-autocomplete').live('mouseleave', function() {
    //$(this).hide();
  //});

  $('#navigation .nav_sections a.sections').bind('mouseenter', function() {
    setup_previewable_nav( $(this) );
  });

  $('#navigation .nav_browse a.browse').bind('mouseenter', function() {
    setup_previewable_nav( $(this) );
  });

  $('#navigation .nav_blog a.blog').bind('mouseenter', function() {
    setup_previewable_nav( $(this) );
  });

  $('#navigation .subnav .left_column li').bind('mouseenter', function() {
    /* set timeouts so that menu items show only if the mouseenter event was 
     * intentional, not an inadvertant hover on the way to the right side of
     * the menu */
    var el = $(this);
    navigation_timeout =  setTimeout( function() {
                            /* set hover states properly */
                            el.closest('.left_column').find('li a').removeClass('hover');
                            el.find('a').addClass('hover');
                            
                            /* show right side */
                            $('#navigation .subnav .right_column li.preview').hide();
                            var preview = $('#navigation .subnav .right_column').find('#' + el.attr('id') + '-preview');
                            preview.show();
                            setup_preview_scroller( preview.find('.text_wrapper') );
                          }, 300);
    
  });

  $('#navigation .subnav .left_column li').bind('mouseleave', function() {
    $('.ui-autocomplete.ui-menu').hide();
    clearTimeout( navigation_timeout );
  });


  $("input[data-autocomplete]#agency-search").each(function(){
    var input = $(this);
    input.autocomplete({
      minLength: 3,
      appendTo: "#agency-search-form",
      position: { of : "input[data-autocomplete]#agency-search" },
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
      open: function( event, ui ) {
        console.log( $(this), ui, event );
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
      appendTo: "#topic-search-form",
      position: { of : "input[data-autocomplete]#topic-search" },
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

  /* Setup calendar as appropriate for navigation view */
  $('#navigation .previewable table.calendar').addClass('no_select');
  $('#navigation .previewable table.cal_first').find('.cal_next').html('');
  $('#navigation .previewable table.cal_last').find('.cal_prev').html('');

});
