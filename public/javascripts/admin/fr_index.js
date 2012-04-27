$(document).ready(function(){
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
              if subject_li.find('

            });    
          }
        }
      }
    });
    return false;
  });
});
