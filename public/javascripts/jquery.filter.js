$(document).ready(function() {
  
  //clear the live search so it's not confusing
  $("#agencies ul.filter li.livesearch input").removeAttr("value");

  
  $("#agencies li.livesearch input").bind("keyup", function(e){
    
    $("#agency_list > li").hide().find("a:regex('\\b" + $(this).attr("value") + "')").parent().show();
    $("#agencies").trigger('filter', $(this).val());  
    
  }).bind("focus", function(e){
    
    $("#agencies ul.filter li").removeClass("on");
    $(this).parent().addClass("on");
    
  });

  $("#agencies ul.filter li a").bind("click", function(e){
    e.preventDefault();
    
    $("#agencies ul.filter li").removeClass("on");
    $(this).parent().addClass("on");
    
    $("#agencies li.livesearch input").attr("value", "Filter agencies");
    
    if($(this).parent().hasClass("all"))
      $("#agency_list > li").show()
    else
      $("#agency_list > li").hide().find("a:regex('^[" + $(this).html() + "]')").parent().show();
      
    $("#agencies").trigger('filter', $(this).text() );  
  });
  
  
  $(".sub_agencies a").bind("click", function(e){
    e.preventDefault();
    
    if( $(this).parent().hasClass("show") ){
      $("#agencies li > ul").show();
    }else {
      $("#agencies li > ul").hide();
    }

    $(".sub_agencies li").removeClass("on");
    $(this).parent().addClass("on");
    
  });
  
  $(".agency_list_container .ordering a").bind('click', function(event) {
    event.preventDefault();
    $(this).hasClass("asc") ?  $("#agency_list>li").tsort() :  $("#agency_list>li").tsort({order:"desc"});
    $(".agency_list_container .ordering li").removeClass("on");
    $(this).parent().addClass("on");
  });
  
  
  $("#agencies").bind('filter', function( event, item ){
    $("#agency_count").html( $("#agency_list > li:visible").size() );
    $("h1.title span").text( 'Agencies - ' + item );
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