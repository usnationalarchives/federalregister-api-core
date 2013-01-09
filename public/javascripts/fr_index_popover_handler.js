/* This file defines a generic fr_index popover handler.
 * Actual use of this handler requires the addition of methods 
 * appropriate to the particular use.
 * The fields to be retrieved from the API (fields) which must
 * include document_number and how to present the 
 * data returned (add_popover_content) are required. */

fr_index_popover_handler = {
  popover_cache: {},
  base_url: 'https://www.federalregister.gov/api/v1/articles/',
  current_el: null,

  initialize: function() {
    return this;
  },

  url: function() {
    return this.base_url + this.current_el.data('document-number') + '.json?' + this.fields;
  },

  get_popover_content: function(el) {
    var popover_handler = this;
    popover_handler.current_el = el;
  
    if( popover_handler.popover_cache[popover_handler.current_el.data('document-number')] === undefined ) {
      $.ajax({
        url: popover_handler.url(),
        dataType: 'jsonp'
      }).done(function(response) {
        popover_handler.ajax_done(response);
      });
    } else {
      popover_handler.add_popover_content();
    }
  },

  ajax_done: function(response) {
    this.popover_cache[response.document_number] = response;
    if( this.current_el.data('document-number') == response.document_number ) {
      this.add_popover_content();
    }
  }
};

