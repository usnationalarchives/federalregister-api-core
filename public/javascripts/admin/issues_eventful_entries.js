$(document).ready(function(){
  function load_new_form(){
    var entry_id = $('div.article[data-internal-id]').first().attr('data-internal-id');
    $('#form').load('/admin/events/new?event[entry_id]=' + entry_id, add_date_picker);
  }

  load_new_form();
  $('.article a.date').click(function(){
    var date = $(this).attr('data-date');
    $('#event_date').val(date);
    return false;
  });
  
  $('.article a.place').click(function(){
    var elem = $(this);
    $('#event_place_id').val(elem.attr('data-id'));
    $('#event_place_name').text(elem.attr('data-name'));

    $('#place_name').val(elem.attr('data-name'));
    $('#place_place_type').val(elem.attr('data-type'));
    $('#place_latitude').val(elem.attr('data-latitude'));
    $('#place_longitude').val(elem.attr('data-longitude'));
    return false;
  });
  
  $('a.delete').live('click', function(){
    var link = $(this);
    var id = link.attr('data-id');
    $.ajax({
      url : '/admin/events/' + id,
      type : 'DELETE',
      success : function() {
        link.closest('li').remove();
      }
    });
  });
  
  $('#form form').live('submit', function(){
    var form = $(this);
    $.ajax({
      url : form.attr('action'),
      type : 'POST',
      data : form.serialize(),
      error : function(req){
        $('#form').html(req.responseText);
      },
      success : function(response) {
        $('#existing_events').append(response);
        load_new_form();
      }
    });
    
    return false;
  });
  
  var header_height = $("#header").height();
  var position = $(window).scrollTop() - header_height;
  
  $(window).bind('scroll', function(event) {
    position = $(window).scrollTop() - header_height;
    if( position > 0 ) {
      $(".events").css("top", $(window).scrollTop() - header_height);
    }
  });
  
  
});

