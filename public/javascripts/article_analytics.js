$(document).ready(function(){

  // previous/next page links
  $('#entries #navigation_controls').on('click', 'a.prev', function() {
    _gaq.push(['_trackEvent', 'Article', 'Links', "Previous Article"]);
  })
  .on('click', 'a.next', function() {
    _gaq.push(['_trackEvent', 'Article', 'Links', "Next Article"]);
  });
});
