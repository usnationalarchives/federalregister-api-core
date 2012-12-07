function highlight_el(event, el) {
  if( event.type == 'mouseleave' ) {
    el.removeClass('hover');
  } else {
    el.addClass('hover');
  }
}

function get_popover_content(el) {
  var base_url = 'https://www.federalregister.gov/api/v1/articles/',
      fields = 'fields%5B%5D=publication_date',
      url = base_url + el.data('document-number') + '.json?' + fields;

  $.ajax({
    url: url,
    dataType: 'jsonp'
  }).done(function(response) {
    console.log(response);
    popover_id = '#popover-' + el.data('document-number');
    $(popover_id).append(response);
  });
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
  

  if ( $("#fr-index-entry-popover-template") !== []) {
    var fr_index_entry_popover_template = Handlebars.compile($("#fr-index-entry-popover-template").html());

    $('body').delegate('.with_ajax_popover', 'mouseenter', function(event) {
      var $el = $(this);
            
      $('.with_ajax_popover').tipsy({ fade: true,
                                      opacity: 1.0,
                                      gravity: 'e',
                                      html: true,
                                      title: function(){
                                        return fr_index_entry_popover_template( {content: new Handlebars.SafeString('<div class="loading">Loading...</div>'),
                                                                                 document_number: $(this).data('document-number')} );
                                      } 
                                    });

      get_popover_content( $el );
    });
  }

});


  
