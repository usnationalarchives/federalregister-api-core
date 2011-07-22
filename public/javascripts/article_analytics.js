$(document).ready(function(){

  // previous/next page links
  $("div.article div#sidebar div#navigation_controls a.prev").bind('click', function() {
    _gaq.push(['_trackEvent', 'Article', 'Links', "Previous Article"]);
  });

  $("div.article div#sidebar div#navigation_controls a.next").bind('click', function() {
    _gaq.push(['_trackEvent', 'Article', 'Links', "Next Article"]);
  });
});
