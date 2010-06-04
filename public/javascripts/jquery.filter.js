$(document).ready(function() {
  
  //clear the live search so it's not confusing
  $("ul.filter li.livesearch input").removeAttr("value");
      
  $("ul.filter li a").bind("click", function(e){
    e.preventDefault();
    $("ul.filter li").removeClass("on");
    $(this).parent().addClass("on");
    
    $("ul.filter li.livesearch input").attr("value", "Filter agencies");
    
    if($(this).parent().hasClass("all"))
      $("ul.agencyList li").show()
    else
      $("ul.agencyList li").hide().find("a:regex('^[" + $(this).html() + "]')").parent().show();
  });
  
  $("ul.filter li.livesearch input").bind("keyup", function(e){
    $("ul.agencyList li").hide().find("a:regex('\\b" + $(this).attr("value") + "')").parent().show();
  });
    
  $("ul.filter li.livesearch input").bind("focus", function(e){
    $("ul.filter li").removeClass("on");
    $(this).parent().addClass("on");
  });

});

jQuery.extend(  
    jQuery.expr[':'], {  
        regex: function(a, i, m, r) {  
            var r = new RegExp(m[3], 'i');  
            return r.test(jQuery(a).text());  
        }  
    }  
);  

jQuery.extend(
  jQuery.expr[':'], {
    Contains: "jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0"
});