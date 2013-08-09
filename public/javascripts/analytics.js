$(document).ready(function(){
  $("a[href^=http]").not('.button.social').bind('click', function(){
    var url = $(this).attr('href');
    if (! url.match(/federalregister\.gov/)) {
      var path = "/external/" + escape(url);
      _gaq.push(['_trackEvent', 'Links', 'External', path]);
    }
  });
  
  
  // track use of calendar features
  $("a.add_to_calendar").bind('click', function() {
    var path = $(this).attr('href') + '/add_to_calendar';
    _gaq.push(['_trackEvent', 'Calendar', 'Add', path]);
  });
  
  $(".result_set.events a.download").bind('click', function() {
    var path = $(this).attr('href');
    _gaq.push(['_trackEvent', 'Calendar', 'Download', path]);
  });
  
  
  $("a.rss").bind('click', function(){
    _gaq.push(['_trackEvent', 'RSS', 'View Modal']);
    return true;
  });
  
  $("a.shorter_url").bind('click', function() {
    var path = $(this).attr('href');
    _gaq.push(['_trackEvent', 'Short URL', 'Shorten', path]);
  });
  
  $('#disclaimer').bind('click', 'a', function(){
    _gaq.push(['_trackEvent', 'Legal Disclaimer', 'View']);
    return true;
  });
  
  // track use of font controls
  $('#font_controls').on('click', 'a.increase', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Increase']);
  });

  $('#font_controls').on('click', 'a.decrease', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Decrease']);
  });
  
  $('#font_controls').on('click', 'a.reset', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Reset']);
  });
  
  $('#font_controls').on('click', 'a.increase', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Increase']);
  });
  
  $('#font_controls').on('click', 'a.sans', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Sans']);
  });
  
  // track use of social features
  $("a.button.social.email").bind('click',
  function (event) {
    _gaq.push(['_trackEvent', 'Social', 'Email', document.location.pathname]);
  });
  $("a.button.social.twitter").bind('click',
  function (event) {
    _gaq.push(['_trackEvent', 'Social', 'Twitter', document.location.pathname]);
  });
  $("a.button.social.facebook").bind('click',
  function (event) {
    _gaq.push(['_trackEvent', 'Social', 'Facebook', document.location.pathname]);
  });

  /* track use of 'submit formal comment' button */
  $('#flash_message.comment a.button').on('click', function() {
    var path = $(this).attr('href'),
        action;

    if( path === "#addresses" ) {
      action = 'Addresses';
    } else {
      action = 'Regulations.gov';
    }

    _gaq.push(['_trackEvent', 'Comments', action]);
  });

  /* track links to regs.gov */
  $('#metadata_content_area #comment_count a').on('click', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Comments', 'metadata_content_area']);
  });
 
  $('.reg_gov_docket_info').on('click', '.reg_gov_docket', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Docket']);
  });

  $('.reg_gov_docket_info').on('click', '.reg_gov_view_comments', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Comments', 'reg_gov_sidebar']);
  });

  $('.reg_gov_docket_info').on('click', '.reg_gov_supporting_documents', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Supporting Documents', 'Individual']);
  });

  $('.reg_gov_docket_info').on('click', '.reg_gov_all_supporting_documents', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Supporting Documents', 'All']);
  });

});
