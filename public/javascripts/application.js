// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
  
  // if($(".daily")){
  //   $(".daily").easySlider({
  //     auto: true,
  //     continuous: true,
  //     pause: 4000,
  //     controlsShow: false,
  //     vertical: true 
  //  });
  // }
  
    // initialize scrollable  
    $("div.daily").scrollable({ 
             
        // items are auto-scrolled in 2 secnod interval 
        interval: 4000,   
        
        vertical: true,
         
        // when last item is encountered go back to first item 
        loop: true,  
         
        // make animation a little slower than the default 
        speed: 600//, 
         
        // // when seek starts make items little transparent 
        // onBeforeSeek: function() { 
        //     this.getItems().fadeTo(300, 0.2);         
        // }, 
        //  
        // // when seek ends resume items to full transparency 
        // onSeek: function() { 
        //     this.getItems().fadeTo(300, 1); 
        // } 
    }); 
});
