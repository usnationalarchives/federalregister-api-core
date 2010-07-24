$(document).ready(function(){
  $("a[href^=http]").bind('click', function(){
    var url = $(this).attr('href');
    if (! url.match(/federalregister\.gov/)) {
      var path = "/external/" + escape(url);
      pageTracker._trackPageview(path);
    }
  });
  
  $("a.add_to_calendar").bind('click', function() {
    var path = $(this).attr('href') + '/add_to_calendar'
    pageTracker._trackPageview(path);
  });
  
  $(".result_set.events a.download").bind('click', function() {
    var path = $(this).attr('href');
    pageTracker._trackPageview(path);
  });
  
  $("a.rss").bind('click', function(){
    var path = window.location.pathname + "/rss_modal";
    pageTracker._trackPageview(path);
    return true;
  });
  
  $("a.shorter_url").bind('click', function() {
    var path = $(this).attr('href');
    pageTracker._trackPageview(path);
  });
  
  $('#disclaimer a').bind('click', function(){
    var path = window.location.pathname + "/legal_disclaimer";
    pageTracker._trackPageview(path);
    return true;
  });
  
  $(["increase", "decrease", "reset", "serif", "sans"]).each(function(i, css_class){
    $('.' + css_class).bind('click', function() {
      var path = window.location.pathname + "/font/" + css_class;
      pageTracker._trackPageview(path);
    });
  });
  
  // articlepage.js has additional analytics
});