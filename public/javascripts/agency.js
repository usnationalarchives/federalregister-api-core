$(document).ready( function() {
  var agency_description_paragraph_limit = 2;
  var agency_sub_agencies_list_limit = 10;

  /* Agency description text read more/less */
  if( $('#agency_description #agency-description-wrapper p:not(.show_hide)').length > agency_description_paragraph_limit ) {
    $('#agency_description #agency-description-wrapper p:not(.show_hide)').each( function(index) {
      if( index > (agency_description_paragraph_limit - 1) ) { $(this).hide(); }
    });
    
    $('#agency_description #agency-description-wrapper').append(
      $('<p>').addClass('show_hide closed').append(
        $('<a>').html('Read more...')
      )
    );
  }

  $('#agency_description #agency-description-wrapper .show_hide').bind('click', function() {
    if( $(this).hasClass('closed') ) {
      $('#agency_description #agency-description-wrapper p:not(.show_hide)').each( function() { $(this).show(); });
      $(this).removeClass('closed').addClass('open').find('a').html('Read less...');
    } else {
      $('#agency_description #agency-description-wrapper p:not(.show_hide)').each( function(index) {
        if( index > (agency_description_paragraph_limit - 1) ) { $(this).hide(); }
      });
      $(this).removeClass('open').addClass('closed').find('a').html('Read more...');
      $(this).scrollintoview({duration: 200});
    }
  });

  /* Agency sub-agency view more/less */
  if( $('#agencies #sidebar .sub_agencies li:not(.show_hide)').length > agency_sub_agencies_list_limit ) {
    $('#agencies #sidebar .sub_agencies li:not(.show_hide)').each( function(index) {
      if( index > (agency_sub_agencies_list_limit - 1) ) { $(this).hide(); }
    });
    
    $('#agencies #sidebar .sub_agencies ul.bullets').append(
      $('<li>').addClass('show_hide closed').append(
        $('<a>').html('View more...')
      )
    );
  }

  $('#agencies #sidebar .sub_agencies li.show_hide').bind('click', function() {
    if( $(this).hasClass('closed') ) {
      $('#agencies #sidebar .sub_agencies li:not(.show_hide)').each( function() { $(this).show(); });
      $(this).removeClass('closed').addClass('open').find('a').html('View less...');
    } else {
      $('#agencies #sidebar .sub_agencies li:not(.show_hide)').each( function(index) {
        if( index > (agency_sub_agencies_list_limit - 1) ) { $(this).hide(); }
      });
      $(this).removeClass('open').addClass('closed').find('a').html('View more...');
      $(this).scrollintoview({duration: 200});
    }
  });

});
