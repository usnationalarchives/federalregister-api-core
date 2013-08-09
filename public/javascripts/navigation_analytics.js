$(document).ready(function(){

  $("#navigation")
  // SECTIONS
  .on('click', '.dropdown.nav_sections .subnav .left_column li a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Sections', $(this).html()]);
  })
  // BROWSE
  .on('click', '.dropdown.nav_browse .subnav .left_column li a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Browse', $(this).html()]);
  })
  // SEARCH
  .on('click', '.dropdown.nav_search .search_list a', function(event) {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', $(this).html()]);
  });

  // STATIC
  $("#nav-home").on('click', 'a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Home', "Home"]);
  });

  $("#nav-blog").on('click', 'a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Blog', "Blog"]);
  });

  // WORDPRESS
  // POLICY
  var policy_item_ul = $('#navigation').find("li.dropdown a.policy").siblings("ul.subnav.wordpress").first();
  $(policy_item_ul).on('click', 'li.page_item a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Policy', $(this).html()]);
  });
  
  // LEARN
  var learn_item_ul = $('#navigation').find("li.dropdown a.learn").siblings("ul.subnav.wordpress").first();
  $(learn_item_ul).on('click', 'li.page_item a', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Learn', $(this).html()]);
  });

  // NAVIGATION SEARCH FORM
  $("div.nav li.inline_search form").bind('submit', function() {
    _gaq.push(['_trackEvent', 'Navigation', 'Search', "Inline Search"]);
  });
});
