$(document).ready(function() {
      
  $("ul.filter li a").bind("click", function(e){
    e.preventDefault();
    $("ul.filter li").removeClass("on");
    $(this).parent().addClass("on");
    if($(this).parent().hasClass("all"))
      $("ul.agencyList li").show()
    else
      $("ul.agencyList li").hide().find("a:regex('^[" + $(this).html() + "]')").parent().show();
  });

  $("ul.filter li:first a").trigger("click");

});

jQuery.extend(  
    jQuery.expr[':'], {  
        regex: function(a, i, m, r) {  
            var r = new RegExp(m[3], 'i');  
            return r.test(jQuery(a).text());  
        }  
    }  
);  