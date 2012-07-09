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
  });
});
