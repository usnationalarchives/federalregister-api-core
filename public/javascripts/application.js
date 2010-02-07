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
         api : true,
         keyboard: false
      });
      scrollable.setPage(index,0);
      
      //init the tooltips for the now loaded list of items
      loadToolTips();
      
    }
  });
  
  //init tooltips for short citation list
  $(".citation a.tip").each(function(){
    
    $(this).qtip({
      content: $(this).siblings("div.tip"),
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
       
  //init tooltips for citation page
  $(".citation-right_tip a.tip").each(function(){
    
    $(this).qtip({
      content: $(this).siblings("div.tip"),
      position: {
          corner: {
             target: 'rightMiddle',
             tooltip: 'leftMiddle'
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
         corner: 'leftMiddle', // We declare our corner within the object using the corner sub-option
         color: '#ddd'
        }   
      }
      
    });
  });         
        
  /*                                   */
  /* Tooltips for featured agency list */
  /*                                   */
  
  $("li.tooltip .info span.help_text").hide();
  $("li.tooltip .info a").each(function(){
    $(this).qtip({
       content: $(this).closest('div.tip') ,
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
  
  var agency_scrollable = $(".viewport").scrollable({ 
    size: 1,
    vertical: true,
    api: true,
    clickable: false
  });
  
  $("ul#featured_agency_buttons a").bind('click', function(event){
    el = $(this);
    event.preventDefault();
    index = el.attr('href').replace(/.*#/, '');
    $('ul.counts').animate({top:-(index*30)}, 'fast');
    // agency_scrollable.seekTo(index);
    $(el).parent().siblings().removeClass("on");
    $(el).parent().addClass("on");
  });
  
  
  /*                                            */
  /* Hide and show congressional member details */
  /*                                            */
  
  $("ul.congressional_members li.member_info a").live('click', function() {
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
  
  $("a[href^=http]").click(function(){
    var url = $(this).attr('href');
    var path = "/external/" + url;
    pageTracker._trackPageview(path);
    return true;
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
