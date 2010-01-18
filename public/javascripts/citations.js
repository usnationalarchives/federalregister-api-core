$(document).ready(function() {

  $("ul.citation_controls li.livesearch input").bind("keyup", function(e){
    $("ul.citation-right_tip li").hide().find(":not('div.tip *'):regex('\\b" + $(this).attr("value") + "')").parent().show();
  });
    
  $("ul.filter li.livesearch input").bind("focus", function(e){
    show_section("#all");    
    $("ul.filter li").removeClass("on");
    $(this).parent().addClass("on");
  });  
  
  var anchor_value = window.location.hash;
  show_section(anchor_value);
  
  $("ul.citation_controls a").bind("click", function(e){
    e.preventDefault();
    $("ul.citation_controls li").removeClass("on");
    show_section( $(this).attr("href") );
  });

});

function show_section(anchor_value){
  switch(anchor_value){
    case '#citations':
      $("#citations").show()
      $("#referencing_entries").hide();
      $("ul.citation_controls li.citations").addClass("on");
      break;
    case '#referencing_entries':
      $("#referencing_entries").show();    
      $("#citations").hide();
      $("ul.citation_controls li.referencing_entries").addClass("on");      
      break;
    case '#all':
      $("#citations").add("#referencing_entries").show();
      $("ul.citation_controls li.all").addClass("on");      
    default:
      break;
  }  
}