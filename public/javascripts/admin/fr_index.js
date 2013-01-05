function highlight_el(event, el) {
  if( event.type === 'mouseleave' ) {
    el.removeClass('hover');
  } else {
    el.addClass('hover');
  }
}

/* fr_index_entry_popover is defined elsewhere we add 
 * the custom methods we need for this instance of it here,
 * Usually this is just the fields to be retrieved from the API 
 * and how to present the data returned. */
fr_index_popover_handler.fields = 'fields%5B%5D=title&fields%5B%5D=toc_subject&fields%5B%5D=toc_doc';
fr_index_popover_handler.add_popover_content = function() {
    var $tipsy_el = $('.tipsy'),
        prev_height = $tipsy_el.height(),
        fr_index_entry_popover_content_template = Handlebars.compile($("#fr-index-entry-popover-content-template").html()),
        popover_id = '#popover-' + this.current_el.data('document-number'),
        new_html = fr_index_entry_popover_content_template( this.popover_cache[this.current_el.data('document-number')] );

    $(popover_id).find('.loading').replaceWith( new_html );

    // bacause we modify the content we need to calculate a new top based on the new height of the popover
    var new_top = parseInt($tipsy_el.css('top'), 10) - ( ($tipsy_el.height() - prev_height) / 2 );
    $tipsy_el.css('top', new_top);
  };


function sort_unique(arr) {
    arr = arr.sort(function (a, b) { return a*1 - b*1; });
    var ret = [arr[0]];
    for (var i = 1; i < arr.length; i++) { // start loop at 1 as element 0 can never be a duplicate
        if (arr[i-1] !== arr[i]) {
            ret.push(arr[i]);
        }
    }
    return ret;
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
    if( event.type === 'mouseleave' ) {
      el.removeClass('hover');
    } else {
      el.addClass('hover');
    }
  });

  var fr_index_subjects = sort_unique($('.fr_index_subject').map(function() { return $(this).val(); }));
  $elements.find('.fr_index_subject').typeahead({
    minLength: 3,
    source: fr_index_subjects
  });
  var fr_index_docs = sort_unique($('.fr_index_doc').map(function() { return $(this).val(); }));
  $elements.find('.fr_index_doc').typeahead({
    minLength: 3,
    source: fr_index_docs
  });

  $elements.find('form').unbind('submit').bind('submit', function(event) {
    var form = $(this);
    event.preventDefault();

    var path = form.attr('action');

    var data = form.serialize();
    $.ajax({
      url: path + '?' + data,
      type: 'PUT',
      datatype: 'json',
      success: function(subjects) {
        var wrapping_list = form.closest('ul.entry_type');
        for( var id in subjects ) {
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
