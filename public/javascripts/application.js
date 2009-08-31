// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(window).unload( function () {
  var scrollable = $("div.daily").data("scrollable");
  index = scrollable.getIndex();
  $.cookie('ticker_index', index)
});

$(document).ready(function() {
  //initialize scrollable
  $.ajax({
    url: "/entries/current-headlines",
    success: function(html){
      var index = $.cookie('ticker_index') || 0;
      
      var ticker = $("div.daily");
      ticker.append(html);
    
      //initialize scrollable
      scrollable = ticker.scrollable({ 
         size: 1,
         interval: 4000,   // items are auto-scrolled in 4 secnod interval 
         horizontal: true,
         loop: true,       // when last item is encountered go back to first item
         speed: 600,       // make animation a little slower than the default
         clickable: false,
         api : true
      });
      scrollable.setPage(index);
    }
  });
    
  /*                                   */
  /* Tooltips for featured agency list */
  /*                                   */
  
  $("li.tooltip .info span.help_text").hide();
  $("li.tooltip .info a").each(function(){
    //console.log($(this).closest('li').children('span.help_text').html());
    help_text = $(this).siblings("span.help_text").html();
    $(this).qtip({
       content: {
          text: help_text
       },
       style: { 
            tip: 'topLeft',
          border: {
              width: 3,
                radius: 8,
                color: '#6699CC'
           }
       }
    });
  });
  
  /*                                    */
  /* Hide and show featured agency list */
  /*                                    */
  
  $("ul.featured_agencies").hide();
  $("ul#agency_count_month").show();
  $("ul#featured_agency_buttons a").bind('click', function(){
    el = $(this);
    $("ul.featured_agencies").hide();
    $("ul#agency_count_"+el.closest('li').attr('id')).show();
    $("ul#featured_agency_buttons li").each(function() {
      $(this).removeClass('on');
    });
    el.closest('li').addClass('on');
    return false;
  });
});
