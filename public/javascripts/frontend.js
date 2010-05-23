$(document).ready(function() {
  
  
  if ($("#flash_message").size() > 0){
    
    $("body").append('<div id="notice_container"><div id="basic-template"><a class="ui-notify-cross ui-notify-close" href="#">x</a><h1>#{title}</h1><p>#{text}</p></div></div>');
    
    $("#notice_container").notify();
    $("#notice_container").notify("create", {
        title: 'Comment Period Ending Soon',
        text: $("#flash_message").html() }, {
        click: function(e,instance){
          // close the notice if the user clicks anywhere inside it
          instance.close();
    }});   
    
  }
  
  
});
