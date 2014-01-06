$(document).ready(function(){
  // SEACH SUGGESTIONS
  $("#search").on('click', '.suggestions .suggestion a', function() {
    _gaq.push(['_trackEvent', 'Search', 'Suggestion', ""]);
  });
});
