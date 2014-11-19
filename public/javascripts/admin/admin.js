$(document).ready(function() {
  try {
    var header_options  = {};
    var header_position = 0;
    $("table.sortable th").each(function(){
      if ($(this).html() === ''){
        header_options += {header_position: {sorter: false}};
      }
      header_position += 1;
    });
    
    $(".sortable").tablesorter({headers: header_options});
  } catch(e) {
    Honeybadger.notify(e);
  }
});

$(document).ajaxSend(function(e, xhr, options) {
  try {
    var token = $("meta[name='csrf-token']").attr("content");
    xhr.setRequestHeader("X-CSRF-Token", token);
  } catch(error) {
    Honeybadger.notify(error);
  }
});

$(document).ajaxError(function(event, request, options) {
  if( request.status === 403 ) {
    window.location = '/admin/login';
  } else if( request.status === 500 ) {
    alert( "We're sorry something went wrong!" );
  }
});

