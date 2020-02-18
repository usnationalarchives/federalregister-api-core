/**
 *
 * @depend fr_index_popover_handler.js
 */

/* fr_index_entry_popover is defined elsewhere we add 
 * the custom methods we need for this instance of it here,
 * Usually this is just the fields to be retrieved from the API 
 * and how to present the data returned. */
fr_index_popover_handler.uses_pi = false;
fr_index_popover_handler.article_fields = 'fields%5B%5D=abstract&fields%5B%5D=comments_close_on&fields%5B%5D=significant&fields%5B%5D=regulations_dot_gov_info&fields%5B%5D=document_number';
fr_index_popover_handler.add_popover_content = function() {
    var $tipsy_el = $('.tipsy'),
        current_dl = this.current_el,
        fr_index_entry_popover_content_template = Handlebars.compile($("#fr-index-entry-popover-content-template").html()),
        popover_id = '#popover-' + current_dl.data('document-number');
    var new_html = fr_index_entry_popover_content_template( this.popover_cache[current_dl.data('document-number')] );

    $(popover_id).find('.loading').replaceWith( new_html );
  };


$(document).ready(function() {
  $('#fr-index-year-select select').on('change', function(e) {
    $(this).closest('form').submit();
  });

  var popover_handler = fr_index_popover_handler.initialize();

  if ( $("#fr-index-entry-popover-template").length > 0) {
    var fr_index_entry_popover_template = Handlebars.compile($("#fr-index-entry-popover-template").html());
  }

  $('body#indexes').delegate('.with_ajax_popover', 'mouseenter', function(event) {
    var $el = $(this);

    /* add tipsy to the element */
    $el.tipsy({ fade: true,
            opacity: 1.0,
            gravity: 'n',
            html: true,
            title: function(){
              return fr_index_entry_popover_template( {content: new Handlebars.SafeString('<div class="loading">Loading...</div>'),
                                                       document_number: $el.data('document-number'),
                                                       title: $el.data('document-title')} );
            } 
          });
    /* trigger show or else it won't be shown until the next mouseenter */
    $el.tipsy("show");
    $('.tipsy.tipsy-n').addClass('popover').css('left', $el.find('dd.document_number').position().left - 300);

    /* get the ajax content and show it */
    popover_handler.get_popover_content( $el );
  });

  $('a.toc_title').on('click', function(event) {
    event.preventDefault();

    $(this).siblings('div.index_entries').toggle();
  });

  $('#indexes .entry_type')
    .find('.comments_received, .comment_open, .significant')
    .tipsy({
      fade: true,
      opacity: 0.8,
      gravity: 's',
      title: function() {
        return $(this).data('tooltip');
      }
    });

  $('#indexes.year .count_pill')
    .tipsy({
      fade: true,
      opacity: 0.8,
      gravity: 's',
      title: function() {
        return $(this).data('tooltip');
      }
    });
});
