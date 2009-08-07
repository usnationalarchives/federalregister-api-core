$(document).ready(function() {
  
  /***********************************  
  * SEARCH FILTER
  **********************************/
 //hide and disable the form on entry
 $("form li:not('.simple')").toggle().find("li").children(":not(label)").disable();
 
 //when the button is clicked - change the button text, toggle the open class, and show/hide enable/disable
  $("a.options").bind("click", function(e){
    e.preventDefault();
    
    if($(this).hasClass("open"))
      $(this).html($(this).html().replace('Hide', "Show"));
    else
      $(this).html($(this).html().replace('Show', "Hide"));
      
    $(this).toggleClass("open");
    
    $("form li:not('.simple')").toggle().find("li").children(":not(label)").toggleDisabled();
  });
  
  
});
