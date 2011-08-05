$(document).ready(function(){
  /*
   *  New header analytics 
   */

  // SECTIONS
  $(".dropdown.nav_sections ul.subnav li a").each(function() {
    $(this).bind('click', function() {
      _gaq.push(['_trackEvent', 'Navigation', 'Sections', $(this).html()]);
    });
  });

  // BROWSE
  $(".dropdown.nav_browse ul.subnav li a").each(function() {
    $(this).bind('click', function() {
      _gaq.push(['_trackEvent', 'Navigation', 'Browse', $(this).html()]);
    });
  });
  
  // SEARCH
  $(".dropdown.nav_browse li#articles-search a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', "Articles"]);
  });

  $(".dropdown.nav_browse li#articles-adv-search a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', "Articles Advanced"]);
  });

  $(".dropdown.nav_browse li#events-search a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', "Events"]);
  });

  $(".dropdown.nav_browse li#regulations-search a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', "Regulations"]);
  });

  // STATIC
  $(".dropdown.nav_browse li#nav-home a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Home', "Home"]);
  });

  $(".dropdown.nav_browse li#nav-blog a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Blog', "Blog"]);
  });

  // WORDPRESS
  // POLICY
  $(".dropdown a.policy").siblings("ul.subnav.wordpress").find("li.page_item a").each(function() {
    $(this).bind('click', function() {
      _gaq.push(['_trackEvent', 'Navigation', 'Policy', $(this).html()]);
    });
  });
  
  // LEARN
  $(".dropdown a.learn").siblings("ul.subnav.wordpress").find("li.page_item a").each(function() {
    $(this).bind('click', function() {
      _gaq.push(['_trackEvent', 'Navigation', 'Learn', $(this).html()]);
    });
  });

  // NAVIGATION SEARCH FORM
  $("div.nav li.inline_search form").bind('submit', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', "Inline Search"]);
  });
});
