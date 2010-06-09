$(document).ready(function() {
  
  $("#topics li.livesearch input").bind("keyup", function(e){
    $("#topic_list > li").hide().find("a:regex('\\b" + $(this).attr("value") + "')").parent().show();
    $("#topic_list").trigger('filter', $(this).val());  
  }).bind("focus", function(e){
    $("#topics ul.filter li").removeClass("on");
    $(this).parent().addClass("on");
  });
  
  $("#topic_list").bind('filter', function( event, item ){
    $("#topic_count").html( $("#topic_list > li:visible").size() );
    $("h1.title span").text( 'Agencies - ' + item );
  });
  
  $(".topic_list_container .ordering a").bind('click', function(event) {
    event.preventDefault();
    
    switch( $(this).attr("href") ){
      case '#asc':
        $("#topic_list>li").tsort('a');
        break;
      case '#dec':
        $("#topic_list>li").tsort('a', {order:"desc"});
        break;
      case '#pop-asc':
        $("#topic_list>li").tsort('.individual_topic_count')
        break;
      case '#pop-dec':
        $("#topic_list>li").tsort('.individual_topic_count',{order:"desc"});
        break;
    }
    
    $(".topic_list_container .ordering li").removeClass("on");
    $(this).parent().addClass("on");
  });
  
});
