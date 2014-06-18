$(document).ready(function(){
  $("a[href^=http]").not('.button.social').bind('click', function(){
    var url = $(this).attr('href');
    if (! url.match(/federalregister\.gov/)) {
      var path = "/external/" + escape(url);
      _gaq.push(['_trackEvent', 'Links', 'External', path]);
    }
  });
  
  
  // track use of calendar features
  $("#search").on('click', 'a.add_to_calendar', function() {
    var path = $(this).attr('href') + '/add_to_calendar';
    _gaq.push(['_trackEvent', 'Calendar', 'Add', path]);
  })
  .on('click', '.result_set.events a.download', function() {
    var path = $(this).attr('href');
    _gaq.push(['_trackEvent', 'Calendar', 'Download', path]);
  });
  
  
/*  $("a.rss").bind('click', function(){
    _gaq.push(['_trackEvent', 'RSS', 'View Modal']);
    return true;
  }); */
  
  $("#sidebar").on('click', 'a.shorter_url', function() {
    var path = $(this).attr('href');
    _gaq.push(['_trackEvent', 'Short URL', 'Shorten', path]);
  });
  
  $('#disclaimer').on('click', 'a', function(){
    _gaq.push(['_trackEvent', 'Legal Disclaimer', 'View']);
    return true;
  });
  
  // track use of font controls

  $('#font_controls').on('click', 'a.increase', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Increase']);
  })
  .on('click', 'a.decrease', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Decrease']);
  })
  .on('click', 'a.reset', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Reset']);
  })
  .on('click', 'a.increase', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Increase']);
  })
  .on('click', 'a.sans', function() {
    _gaq.push(['_trackEvent', 'Font Controls', 'Sans']);
  });
  
  // track use of social features
  var meta_data_content_area = $('#meta_data_content_area');
  $(meta_data_content_area).on('click', 'a.button.social.email', function () {
    _gaq.push(['_trackEvent', 'Social', 'Email', document.location.pathname]);
  })
  .on('click', 'a.button.social.twitter', function () {
    _gaq.push(['_trackEvent', 'Social', 'Twitter', document.location.pathname]);
  })
  .on('click', 'a.button.social.facebook', function () {
    _gaq.push(['_trackEvent', 'Social', 'Facebook', document.location.pathname]);
  });

  /* track links to regs.gov */
  meta_data_content_area.on('click', '#comment_count a', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Comments', 'metadata_content_area']);
  });

  var reg_gov_docket_info = $('#sidebar').find('div.reg_gov_docket_info');
  reg_gov_docket_info.on('click', '.reg_gov_docket', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Docket']);
  })
  .on('click', '.reg_gov_view_comments', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Comments', 'reg_gov_sidebar']);
  })
  .on('click', '.reg_gov_supporting_documents', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Supporting Documents', 'Individual']);
  })
  .on('click', '.reg_gov_all_supporting_documents', function() {
    _gaq.push(['_trackEvent', 'Regulations.gov', 'View Supporting Documents', 'All']);
  });

});
