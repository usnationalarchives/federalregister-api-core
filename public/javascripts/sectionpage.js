$(document).ready(function() {
  
  if( $("#comments-closing-opening").size() > 0){
    $("#comments-closing-opening").tabs({
      trackState: true,
      srcPath: '/blank.html'
    });
    
    $(".TOC a").bind('click', function(event) {
      $(window).scrollTop( $("#comments-closing-opening").offset().top);
    });
  }
  
});
