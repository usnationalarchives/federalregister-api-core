$(document).ready(function(){
  // SEACH SUGGESTIONS
  $(".suggestions .suggestion a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Search', 'Suggestion', ""]);
  });
});
