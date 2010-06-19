$(document).ready(function() {  
  $("#timeline .timeline_list").width( $("#timeline .timeline_list > li").size() * $("#timeline .timeline_list > li").outerWidth(true) );
  new Dragdealer('timeline', {
    x: 1
  });
});
