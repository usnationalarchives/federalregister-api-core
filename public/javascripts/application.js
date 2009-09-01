// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(window).unload( function () {
  var scrollable = $("div.daily").data("scrollable");
  $.cookie('ticker_index', scrollable.getIndex());
});

$(document).ready(function() {
  //initialize scrollable
  $.ajax({
    url: "/entries/current-headlines",
    success: function(html){
      var index = $.cookie('ticker_index') || 0;
      $('#ticker').replaceWith(html);
      var ticker = $("div.daily");
    
      //initialize scrollable
      var scrollable = ticker.scrollable({ 
         size: 1,
         interval: 4000,   // items are auto-scrolled in 4 secnod interval 
         horizontal: true,
         loop: true,       // when last item is encountered go back to first item
         speed: 600,       // make animation a little slower than the default
         clickable: false,
         api : true
      });
      scrollable.setPage(index,0);
      
      //init the tooltips for the now loaded list of items
      loadToolTips();
      
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

function loadToolTips() {
        
  //init tooltips for ticker
  $("ul.items li a.entry").each(function(){
    
    $(this).qtip({
      content: $(this).parent().children('div.tip'),
      position: {
          corner: {
             target: 'bottomMiddle',
             tooltip: 'topMiddle'
          }
      },
      style: {
       name: 'light',
       padding: 5,
       width: 530,
       border: {
         width: 7,
         radius: 5,
         color: '#ddd'
         },
      tip: { // Now an object instead of a string
         corner: 'topMiddle', // We declare our corner within the object using the corner sub-option
         color: '#ddd'
        }   
      }
      
    });
  });
}
