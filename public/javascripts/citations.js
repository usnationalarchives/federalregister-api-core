$(document).ready(function() {
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
    default:
      break;
  }  
}