$(document).ready(function() {
  
  var bg_width = 500;
  var li_width = 230;
  
  $("ul.count:last").each(function(){
    var max = find_max($(this));
    li_width = $("ul.count").width();
    
    $(this).find("li").each(function(){
      var i = parseInt( $(this).find(".count").html() );
      var p = i / max;
      var offset = Math.round(bg_width - (li_width * p));
      //$(this).find(".bg").css("width", Math.round(p*100) + "%" );
      
      $(this).css("background-position", -offset + "px top" );
    })
    
  });
});

function find_max(list){
  var max = 0;

  $(list).find(".count").each(function(){
    var i = parseInt( $(this).html() );
    if(i > max)
      max = i; 
  });
  
  return max;  
}