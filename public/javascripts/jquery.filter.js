$(document).ready(function() {
    
  $("ul.filter li a").bind("click", function(e){
    e.preventDefault();
    $("ul.agencyList li").hide().find("a:regex('^[" + $(this).html() + "]')").parent().show();
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