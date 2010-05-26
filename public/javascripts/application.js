$(document).ready(function() {


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
