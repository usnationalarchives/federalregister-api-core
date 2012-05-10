function highlight_el(event, el) {
  if( event.type == 'mouseleave' ) {
    el.removeClass('hover');
  } else {
    el.addClass('hover');
  }
}

$(document).ready(function(){
  $('#content_area form').hide();
  $('#content_area ul.entry_type a.edit').on('click', function(event) {
    event.preventDefault();

    var link = $(this);
    var form = link.siblings('form').first();
    var el   = link.closest('li');
    

    if( form.css('display') === 'none' ) {
      link.html('Cancel');
      form.show();
      el.removeClass('hover');
    } else {
      link.html('Edit');
      form.hide();
      el.addClass('hover');
    }
  });

  $('#content_area ul.entry_type a.edit').on('hover', function(event) {
    highlight_el(event, $(this).closest('li'));
  });

  $('form').bind('submit', function() {
    var form = $(this);
    var path = form.attr('action'); 
    console.log(form.serialize());
    $.ajax({
      url: path,
      type: 'PUT',
      data: form.serialize(),
      datatype: 'json',
      success: function(subjects) {
        var wrapping_list = form.closest('ul.entry_type');
        for( id in subjects ) {
          $('#' + id).remove();
          if (subjects[id]) {
            var new_element = $(subjects[id]);
            var title = new_element.find('span.title').first().text();
            wrapping_list.children.each(function() {
              var subject_li = $(this);
              //if subject_li.find('

            });
          }
        }
      }
    });
    return false;
  });
});
