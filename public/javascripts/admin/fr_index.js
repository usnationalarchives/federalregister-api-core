function highlight_el(event, el) {
  if( event.type == 'mouseleave' ) {
    el.removeClass('hover');
  } else {
    el.addClass('hover');
  }
}

function get_popover_content(el) {
  var base_url = 'https://www.federalregister.gov/api/v1/articles/',
      fields = 'fields%5B%5D=title&fields%5B%5D=toc_subject&fields%5B%5D=toc_doc',
      url = base_url + el.data('document-number') + '.json?' + fields;
      
  $.ajax({
    url: url,
    dataType: 'jsonp'
  }).done(function(response) {
    var $tipsy_el = $('.tipsy'),
        prev_height = $tipsy_el.height(),
        fr_index_entry_popover_content_template = Handlebars.compile($("#fr-index-entry-popover-content-template").html()),
        popover_id = '#popover-' + el.data('document-number');

    $(popover_id).find('.loading').replaceWith( fr_index_entry_popover_content_template(response) );

    // bacause we modify the content we need to calculate a new top based on the new height of the popover
    var new_top = parseInt($tipsy_el.css('top'), 10) - ( ($tipsy_el.height() - prev_height) / 2 );
    $tipsy_el.css('top', new_top);
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
                                                                                 document_number: $(this).data('document-number'),
                                                                                 title: 'Original ToC Data'} );
                                      } 
                                    });

      get_popover_content( $el );
    });
  }

});


  
