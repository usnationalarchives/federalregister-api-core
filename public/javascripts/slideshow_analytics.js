function promo_selected(link) {
  return $(link).closest('li').hasClass('on') ? 1 : 0;
}

$(document).ready(function(){
  /*
   *  Top news slideshow highlight box analytics 
   */

  // SECTIONS
  $(".aside_box.section_nav a#promo_money").bind('click', function() {
    _gaq.push(['_trackEvent', 'Slide Show', 'Sections', "Money", promo_selected(this)]);
  });

  $(".aside_box.section_nav a#promo_environment").bind('click', function() {
    _gaq.push(['_trackEvent', 'Slide Show', 'Sections', "Environment", promo_selected(this)]);
  });

  $(".aside_box.section_nav a#promo_world").bind('click', function() {
    _gaq.push(['_trackEvent', 'Slide Show', 'Sections', "World", promo_selected(this)]);
  });

  $(".aside_box.section_nav a#promo_science-and-technology").bind('click', function() {
    _gaq.push(['_trackEvent', 'Slide Show', 'Sections', "Science and Technology", promo_selected(this)]);
  });

  $(".aside_box.section_nav a#business-and-industry").bind('click', function() {
    _gaq.push(['_trackEvent', 'Slide Show', 'Sections', "Business and Industry", promo_selected(this)]);
  });

  $(".aside_box.section_nav a#health-and-public-welfare").bind('click', function() {
    _gaq.push(['_trackEvent', 'Slide Show', 'Sections', "Health and Public Welfare", promo_selected(this)]);
  });
});
