$(document).ready(function() {
    $("ul.count").each(function(){
      var max = find_max($(this));
      var val = 0;
      var percent_of_width = 0;
    
      $(this).find("li").each(function(){
        val = parseInt( $(this).find(".count").html() );
        percent_of_width = Math.round((val / max) * 100);
        $(this).find(".bg").animate({"width": percent_of_width + "%"}, 1500 );
      });
  });
});

function find_max(list){
  var max = 0;
  var val = 0;
  
  $(list).find(".count").each(function(){
    val = parseInt( $(this).html() );
    if(val > max)
      max = val; 
  });
  
  return max;  
}
