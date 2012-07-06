function set_doc_type_search_filter(el) {
  if ( el.hasClass('on') ) {
    el.removeClass('on');
    el.removeClass('hover');

    el.data('tooltip', 'Limit search articles of type ' + el.data('filter-doc-type-display') );
    el.tipsy('hide');
    el.tipsy('show');

    $('#conditions_type_input input#conditions_type_' + el.data('filter-doc-type')).removeAttr('checked');
    $('#conditions_type_input input#conditions_type_' + el.data('filter-doc-type')).trigger('calculate_expected_results');
  } else {
    el.addClass('on');

    el.data('tooltip', 'Remove limitation (articles of type ' + el.data('filter-doc-type-display') + ')' );
    el.tipsy('hide');
    el.tipsy('show');

    $('#conditions_type_input input#conditions_type_' + el.data('filter-doc-type')).attr('checked', true);
    $('#conditions_type_input input#conditions_type_' + el.data('filter-doc-type')).trigger('calculate_expected_results');
  }

}

$(document).ready( function() {
  $('#doc-type-search-filter li').each( function() {
    $(this).data('tooltip', 'Limit search to articles of type ' + $(this).data('filter-doc-type-display') );
  });

  $('#conditions_type_input input#conditions_type_' + $('#doc-type-search-filter li').first().data('filter-doc-type')).trigger('calculate_expected_results');

  $('#doc-type-search-filter li').bind('mouseenter', function(event) {
    $(this).addClass('hover');
  });

  $('#doc-type-search-filter li').bind('mouseleave', function(event) {
    $(this).removeClass('hover');
  });

  $('#doc-type-search-filter li').bind('click', function(event) {
    set_doc_type_search_filter( $(this) );
  });
});
