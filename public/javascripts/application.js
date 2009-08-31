// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(window).unload( function () {
  var scrollable = $("div.daily").data("scrollable");
  index = scrollable.getIndex();
  $.cookie('ticker_index', index)
});

$(document).ready(function() {


    var items = $("div.daily .items")
    var index = $.cookie('ticker_index') || 0;
    
    //initialize scrollable  
    scrollable = $("div.daily").scrollable({ 
        size: 1,
        
        // items are auto-scrolled in 4 secnod interval 
        interval: 4000,   
        
        horizontal: true,
         
        // when last item is encountered go back to first item 
        loop: true,  
         
        // make animation a little slower than the default 
        speed: 600,
        
        clickable: false,
        api : true
    });
    
    scrollable.setPage(index);
        
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
  
  var agency_scrollable = $("div.featured_agencies").scrollable({ 
    size: 1,
    vertical: false,
    api: true,
    clickable: false
  });
  
  $("ul#featured_agency_buttons a").bind('click', function(){
    el = $(this);
    el.preventDefault;
    index = el.attr('href').replace(/.*#/, '');
    agency_scrollable.seekTo(index);
    $(el).parent().siblings().removeClass("on");
    $(el).parent().addClass("on");
    console.log(agency_scrollable.getItems());
    console.log(agency_scrollable.getPageIndex());
    console.log(agency_scrollable.getConf());
  });
  
  
  /*                                            */
  /* Hide and show congressional member details */
  /*                                            */
  
  $("ul.congressional_members li.member_info a").bind('click', function() {
    el = $(this);
    
    li = el.closest('li');
    id = el.attr('href');
    var detail_span = $("ul.congressional_members span"+id);
    
    if(li.hasClass('more') ) {
      detail_span.show();
      el.text('(hide details)');
      li.toggleClass('more');
      li.toggleClass('less');
    }
    else if(li.hasClass('less')) {
      detail_span.hide();
      el.text('(view details)');
      li.toggleClass('more');
      li.toggleClass('less');
    }
    
    return false;
  });
  
});
