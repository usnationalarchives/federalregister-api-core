$(document).ready(function() {
  
  //clear the live search so it's not confusing
  $("#agencies ul.filter li.livesearch input").removeAttr("value");
  
  $("#agencies li.livesearch input").bind("keyup", function(e){
    $("#agency_list > li").hide().find("a:regex('\\b" + $(this).attr("value") + "')").parent().show();
    $("#agencies").trigger('filter', $(this).val());  
  }).bind("focus", function(e){
    $("#agencies .filters ul.actions li").removeClass("on");
    $(this).parent().addClass("on");
  });



  $("#agencies .filters .alpha li a").bind("click", function(e){
    e.preventDefault();
    
    $("#agencies .filters .alpha li").removeClass("on");
    $(this).parent().addClass("on");
        
    if($(this).parent().hasClass("all"))
      $("#agency_list > li").show()
    else
      $("#agency_list > li").hide().find("a:regex('^[" + $(this).html() + "]')").parent().show();
      
    $("#agencies").trigger('filter', $(this).text() );  
  });
  
  
  $(".sub_agencies a").bind("click", function(e){
    e.preventDefault();
    $(this).parent().hasClass("show") ? $("#agencies li > ul").show() : $("#agencies li > ul").hide();
    $(".sub_agencies li").removeClass("on");
    $(this).parent().addClass("on");
  });
  
  $(".agency_list_container .actions a").bind('click', function(event) {
    event.preventDefault();
    $(this).hasClass("asc") ?  $("#agency_list>li").tsort() :  $("#agency_list>li").tsort({order:"desc"});
    $(".agency_list_container .actions li").removeClass("on");
    $(this).parent().addClass("on");
  });
  
  
  $("#agencies").bind('filter', function( event, item ){
    $("#agency_count").html( $("#agency_list > li:visible").size() );
    $("h1.title span").text( 'Agencies - ' + item );
  });

});