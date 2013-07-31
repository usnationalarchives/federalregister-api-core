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
    var path = window.location.pathname + "/rss_modal";
    _gaq.push(['_trackEvent', 'RSS', 'View Modal', path]);
    return true;
  });
  
  $("a.shorter_url").bind('click', function() {
    var path = $(this).attr('href');
    _gaq.push(['_trackEvent', 'Short URL', 'Shorten', path]);
  });
  
  $('#disclaimer a').bind('click', function(){
    var path = window.location.pathname + "/legal_disclaimer";
    _gaq.push(['_trackEvent', 'Legal Disclaimer', 'View', path]);
    return true;
  });
  
  // track use of font controls
  $("a.increase").bind('click', function() {
    var path = window.location.pathname + "/font/increase";
    _gaq.push(['_trackEvent', 'Font Controls', 'Increase', path]);
  });
  
  $("a.decrease").bind('click', function() {
    var path = window.location.pathname + "/font/decrease";
    _gaq.push(['_trackEvent', 'Font Controls', 'Decrease', path]);
  });
  
  $("a.reset").bind('click', function() {
    var path = window.location.pathname + "/font/reset";
    _gaq.push(['_trackEvent', 'Font Controls', 'Reset', path]);
  });
  
  $("a.serif").bind('click', function() {
    var path = window.location.pathname + "/font/serif";
    _gaq.push(['_trackEvent', 'Font Controls', 'Serif', path]);
  });
  
  $("a.sans").bind('click', function() {
    var path = window.location.pathname + "/font/sans";
    _gaq.push(['_trackEvent', 'Font Controls', 'Sans', path]);
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
    var path = $(this).href,
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
    
  $('.reg_gov_docket_info .reg_gov_docket').on('click', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Docket']);
  });
  $('.reg_gov_docket_info .reg_gov_view_comments').on('click', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Comments', 'reg_gov_sidebar']);
  });
  $('.reg_gov_docket_info .reg_gov_supporting_documents').on('click', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Supporting Documents', 'Individual']);
  });
  $('.reg_gov_docket_info .reg_gov_all_supporting_documents').on('click', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Supporting Documents', 'All']);
  });

});
