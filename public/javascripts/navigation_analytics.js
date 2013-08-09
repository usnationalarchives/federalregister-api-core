$(document).ready(function(){
  /*
   *  New header analytics 
   */

  // SECTIONS
  $(".dropdown.nav_sections").on('click', '.subnav .left_column li a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Sections', $(this).html()]);
  });

  // BROWSE
  $(".dropdown.nav_browse").on('click', '.subnav .left_column li a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Browse', $(this).html()]);
  });
  
  // SEARCH
  $(".dropdown.nav_search").on('click', '.search_list a', function(event) {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', $(this).html()]);
  });

  // STATIC
  $("li#nav-home").on('click', 'a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Home', "Home"]);
  });

  $("li#nav-blog").on('click', 'a', function() {
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
