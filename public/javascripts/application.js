$(document).ready(function() {
  $("#search_bar #conditions_term").inlinelabel();
});


function unimplemented() {
  alert("This feature is not implemented yet.");
}

//http://groups.google.com/group/jquery-en/browse_thread/thread/a890828a14d86737
//modified by DMA to use outerHeight, outerWidth
jQuery.fn.centerScreen = function(loaded) {
  var obj = this;
  if(!loaded) {
    obj.css('left', $(window).width()/2-this.outerWidth()/2);
    $(window).resize(function(){ 
      obj.centerScreen(!loaded); 
      });
  } else {
    obj.stop();
    obj.animate(
      { left: $(window).width()/2-this.outerWidth()/2 }, 200, 'linear');
    }
  return obj;  
  }