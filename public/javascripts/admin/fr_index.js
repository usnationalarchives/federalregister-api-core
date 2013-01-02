function highlight_el(event, el) {
  if( event.type == 'mouseleave' ) {
    el.removeClass('hover');
  } else {
    el.addClass('hover');
  }
}


function initializeFrIndexEditor(elements) {
  var $elements = $(elements);
  $elements.find('form').hide();
  $elements.find('a.edit').on('click', function(event) {
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

  $elements.find('a.edit').on('hover', function(event) {
    var el = $(this).closest('li');
    if( event.type == 'mouseleave' ) {
      el.removeClass('hover');
    } else {
      el.addClass('hover');
    }
  });

  $elements.find('form').unbind('submit').bind('submit', function(event) {
    var form = $(this);
    console.log(form);
    event.preventDefault();

    var path = form.attr('action');

    var data = form.serialize();
    console.log(path);
    console.log(data);
    $.ajax({
      url: path + '?' + data,
      type: 'PUT',
      datatype: 'json',
      success: function(subjects) {
        var wrapping_list = form.closest('ul.entry_type');
        for( id in subjects ) {
          $('#' + id).remove();
          var element_to_insert = subjects[id];

          if (element_to_insert) {
            var text = $(element_to_insert).find('span.title:first').text();
            var added_element;

            wrapping_list.children('li').each(function() {
              var list_item = $(this);
              if (list_item.find('span.title:first').text() > text) {
                added_element = $(element_to_insert).insertBefore(list_item).fadeIn("fast");
                return false;
              }
            });

            if (!added_element) {
              added_element = $(element_to_insert).appendTo(wrapping_list).fadeIn("fast");
            }
            console.log(added_element);

            initializeFrIndexEditor(added_element);
          }
        }
      }
    });
    return false;
  });
}

$(document).ready(function() {
  $('#content_area form').hide();
  initializeFrIndexEditor($('#content_area ul.entry_type > li'));

  var popover_handler = fr_index_popover_handler.initialize();
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

      popover_handler.get_popover_content( $el );
    });
  }
});
