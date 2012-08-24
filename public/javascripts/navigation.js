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

  $('#navigation .dropdown').bind('mouseenter', function(event) {
    var dropdown = $(this);
    /* ensure other menus close - this covers odd edge cases that
     * bypass mouseleave (opening another tab, switching apps, etc). */
    /* also, shouldn't need the added find scope after siblings - 
     * but IE requires it or you get a big nasty loop... */
    dropdown.siblings().find('.dropdown').trigger('mouseleave');

    dropdown.find('a.top_nav').addClass('hover');
    dropdown.find('.subnav').show();

    if( dropdown.hasClass('nav_sections') || dropdown.hasClass('nav_browse') || dropdown.hasClass('nav_blog') ) {
      setup_previewable_nav( dropdown.find('a.top_nav') );
    }
  });

  $('#navigation .dropdown').bind('mouseleave', function(event) {
    $(this).find('.subnav').hide();
    $(this).find('a.top_nav').removeClass('hover');
  });

  $('#navigation .subnav .left_column a').bind('click', function(event) {
    /* this is to support touch enabled devices where the first click 
     * is actually a hover on these menus */
    if( ! $(this).hasClass('hover') ) {
      event.preventDefault();
    }
  });

  $('#navigation .subnav').bind('mouseenter', function() {
    $(this).closest('.dropdown').find('a.top_nav').addClass('hover');
  });
  
  $('#navigation .subnav').bind('mouseleave', function() {
    $(this).closest('.dropdown').find('a.top_nav').removeClass('hover');
    $(this).hide();
    
    /* check to see if the mouse pointer in now over the main navigation dropdowns,
     * if it is then trigger mouseenter once more (it doesn't fire by default because
     * subnav's are containted within the dropdown and thus haven't left yet...) */
    if( $(document.elementFromPoint(event.clientX, event.clientY)).parent().hasClass('dropdown') ) {
      $(document.elementFromPoint(event.clientX, event.clientY)).parent().trigger('mouseenter');
    }
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
