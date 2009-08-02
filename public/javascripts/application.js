// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
  
    // initialize scrollable  
    $("div.daily").scrollable({ 
             
        // items are auto-scrolled in 2 secnod interval 
        interval: 4000,   
        
        vertical: true,
         
        // when last item is encountered go back to first item 
        loop: true,  
         
        // make animation a little slower than the default 
        speed: 600
    });

  /*                                   */
  /* Tooltips for featured agency list */
  /*                                   */
  
  $("li.tooltip span.help_text").hide();
  $("li.tooltip a").each(function(){
    //console.log($(this).closest('li').children('span.help_text').html());
    help_text = $(this).closest('li').children('span.help_text').html()
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
  $("ul#featured_agency_buttons").each(function(){
    $(this).children('a').bind('click', function(){
      el = $(this);
      //$("ul.featured_agencies").hide();
      console.log(el);//$("ul#agency_count_"+el.closest('li').attr('id')));
      //$("ul#agency_count_"+el.closest('li').attr('id')).show();
    })
  });
});
