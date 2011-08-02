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


  /* 
   *  Old header analytics 
   */

  // SECTIONS
  $("#primary_nav li.money a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Money"]);
  });

  $("#primary_nav li.environment a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Environment"]);
  });

  $("#primary_nav li.world a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Sections', "World"]);
  });

  $("#primary_nav li.science-and-technology a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Science and Technology"]);
  });

  $("#primary_nav li.business-and-industry a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Business and Industry"]);
  });

  $("#primary_nav li.health-and-public-welfare a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Health and Public Welfare"]);
  });

  // STATIC
  $("#primary_nav li.blog a").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Blog', "Blog"]);
  });

  // NAVIGATION SEARCH FORM
  $("div#header #search_bar #search_container form").bind('submit', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', "Inline Search"]);
  });

  // BROWSE
  $("#primary_nav #search_bar #browse_container a#agencies-browse").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Browse', "Agencies"]);
  });

  $("#primary_nav #search_bar #browse_container a#topics-browse").bind('click', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Browse', "Topics"]);
  });

});
