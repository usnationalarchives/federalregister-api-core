/* 
 *  New header analytics 
 */

// SECTIONS
$(".dropdown.nav_sections li#money a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Money"]);
});

$(".dropdown.nav_sections li#environment a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Environment"]);
});

$(".dropdown.nav_sections li#world a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Sections', "World"]);
});

$(".dropdown.nav_sections li#science-and-technology a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Science and Technology"]);
});

$(".dropdown.nav_sections li#business-and-industry a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Business and Industry"]);
});

$(".dropdown.nav_sections li#health-and-public-welfare a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Sections', "Health and Public Welfare"]);
});

// BROWSE
$(".dropdown.nav_browse li#agencies-browse a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Browse', "Agencies"]);
});

$(".dropdown.nav_browse li#topics-browse a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Browse', "Topics"]);
});

$(".dropdown.nav_browse li#current-article-browse a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Browse', "Current Article"]);
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
$(".dropdown li.page-item-50 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Policy', "About Us"]);
});

$(".dropdown li.page-item-52 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Policy', "Legal Status"]);
});

$(".dropdown li.page-item-54 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Policy', "User Information"]);
});

$(".dropdown li.page-item-56 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Policy', "Contact Us"]);
});

$(".dropdown li.page-item-58 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Policy', "Privacy"]);
});

$(".dropdown li.page-item-60 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Policy', "Accessibility"]);
});

$(".dropdown li.page-item-62 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Policy', "FOIA"]);
});

$(".dropdown li.page-item-64 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Policy', "No Fear Act"]);
});

// LEARN
$(".dropdown li.page-item-14 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Learn', "FR Tutorials & History"]);
});

$(".dropdown li.page-item-345 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Learn', "Public Inspection"]);
});

$(".dropdown li.page-item-38 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Learn', "Related Resources"]);
});

$(".dropdown li.page-item-40 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Learn', "Doc Drafting & Research"]);
});

$(".dropdown li.page-item-42 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Learn', "Regulatory Journals"]);
});

$(".dropdown li.page-item-553 a").bind('click', function() {
  _gaq.push(['_trackEvent', 'Navigation', 'Learn', "Regulatory Improvement"]);
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

