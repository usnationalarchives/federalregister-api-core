/**
 *
 * @depend fr_index_popover_handler.js
 */


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
fr_index_popover_handler.fields = 'fields%5B%5D=title&fields%5B%5D=toc_subject&fields%5B%5D=toc_doc&fields%5B%5D=document_number';
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


/* returns the current state of toc subject and doc titles as users make edits */
function current_toc_subjects() {
  return _.uniq($('.fr_index_subject').map(function() { return $(this).val(); }));
}
function current_toc_docs() {
  return _.uniq($('.fr_index_doc').map(function() { return $(this).val(); }));
}

/* using a function as the source for these typeaheads allows
 * them to stay up to date with changes on the page.
 * if just an array is provided that is cached and not updated */
function fr_index_toc_subject_typeahead(elements) {
  elements.find('.fr_index_subject').typeahead({
    minLength: 3,
    source: current_toc_subjects()
  });
}
function fr_index_toc_doc_typeahead(elements) {
  elements.find('.fr_index_doc').typeahead({
    minLength: 3,
    source: current_toc_docs()
  });
}

function insert_index_element( element, list_item ) {
  element.insertBefore(list_item)
         .scrollintoview({duration: 300, complete: function() {
            element.effect("highlight", {color: '#f5f8f9'}, 2000);
          }
         });
}

function hide_top_level_index_form(form) {
  form.hide();
  form.closest('li').removeClass('edit').find('a.cancel').first().removeClass('cancel').addClass('edit').html('Edit');
}

function initializeFrIndexEditor(elements) {
  var $elements = $(elements);
  
  $elements.find('a.edit').on('click', function(event) {
    event.preventDefault();

    var link = $(this);
    var form = link.siblings('form').first();
    var top_level_form = null;
    if( ! form.hasClass('top_level') ) {
      top_level_form = link.closest('ul').
                            closest('li').
                            find('form.top_level').
                            first();
    }
    var el   = link.closest('li');
    

    if( form.css('display') === 'none' ) {
      if( top_level_form ) {
        hide_top_level_index_form(top_level_form);
      }

      link.removeClass('edit').addClass('cancel').html('Cancel');
      link.closest('li').addClass('edit');
      form.show();
      form.find('input[type!=hidden]').last().scrollintoview();
      form.find('input[type!=hidden]').first().focus();
      el.removeClass('hover');
    } else {
      link.removeClass('cancel').addClass('edit').html('Edit');
      form.hide();
      link.closest('li').removeClass('edit');
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

  fr_index_toc_subject_typeahead($elements);
  fr_index_toc_doc_typeahead($elements);

  $elements.find('form').unbind('submit').bind('submit', function(event) {
    var form = $(this);
    var submit_button = form.find('input[type=submit]').first();

    event.preventDefault();

    /* visually identify form as being saved */
    form.addClass('disabled');
    submit_button.val('Saving');
    form.siblings('a.cancel').hide();

    var path = form.attr('action');

    var data = form.serialize();
    $.ajax({
      url: path + '?' + data,
      type: 'PUT',
      datatype: 'json',
      success: function(subjects) {
        /* set form back to normal while it's still available */
        form.removeClass('disabled');
        submit_button.val('Save');
        form.siblings('a.cancel').show();

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
                added_element = insert_index_element( $(element_to_insert), list_item );
                return false;
              }
            });

            if (!added_element) {
              added_element = $(element_to_insert).appendTo(wrapping_list).fadeIn(300);
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

  $('a.wrapper').on('click', function(event) {
    $(this).closest('li').find('ul.entry_details').toggle();
  });

  initializeFrIndexEditor($('#content_area ul.entry_type > li'));

  var popover_handler = fr_index_popover_handler.initialize();
  if ( $("#fr-index-entry-popover-template") !== []) {
    var fr_index_entry_popover_template = Handlebars.compile($("#fr-index-entry-popover-template").html());
        
    $('body').delegate('.with_ajax_popover', 'mouseenter', function(event) {
      var $el = $(this);
            
      /* add tipsy to the element */
      $el.tipsy({ fade: true,
                  opacity: 1.0,
                  gravity: 'e',
                  html: true,
                  title: function(){
                    return fr_index_entry_popover_template( {content: new Handlebars.SafeString('<div class="loading">Loading...</div>'),
                                                             document_number: $(this).data('document-number'),
                                                             title: 'Original ToC Data'} );
                  } 
                });
      /* trigger the show or else it won't be shown until the next mouseover */
      $el.tipsy("show");

      /* get the ajax content and show it */
      popover_handler.get_popover_content( $el );
    });
  }
});
