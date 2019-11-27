/* This file defines a generic fr_index popover handler.
 * Actual use of this handler requires the addition of methods 
 * appropriate to the particular use.
 * The fields to be retrieved from the API (fields) which must
 * include document_number and how to present the 
 * data returned (add_popover_content) are required. */

/*global fr_index_popover_handler:true */
fr_index_popover_handler = {
  popover_cache: {},
  pi_base_url: 'https://www.federalregister.gov/api/v1/public-inspection-documents/',
  article_base_url: 'https://www.federalregister.gov/api/v1/articles/',
  current_el: null,
  article_fields: 'fields%5B%5D=title&fields%5B%5D=document_number',
  uses_pi: true,

  initialize: function() {
    return this;
  },

  url: function() {
    if( this.uses_pi ) {
      return this.pi_base_url + this.current_el.data('document-number') + '.json?' + this.fields;
    } else { 
      return this.article_url();
    }
  },

  article_url: function() {
    return this.article_base_url + this.current_el.data('document-number') + '.json?' + this.article_fields;
  },

  get_popover_content: function(el) {
    var popover_handler = this;

    popover_handler.current_el = el;
     
    if( popover_handler.popover_cache[popover_handler.current_el.data('document-number')] === undefined ) {
      $.ajax({
        url: popover_handler.url(),
        dataType: 'jsonp'
      }).done(function(response) {
        if( popover_handler.uses_pi ) {
          var pi_response = response;
          /* need to get the title from the document end point and then 
           * pass the whole thing as a single object to handlebars */
          $.ajax({
            url: popover_handler.article_url(),
            dataType: 'jsonp'
          }).done(function(response) {
            pi_response.title = response.title;
            pi_response.document_number = response.document_number;
            popover_handler.ajax_done(pi_response);
          });
        } else {
          popover_handler.ajax_done(response);
        }
      });
    } else {
      popover_handler.add_popover_content();
    }
  },

  ajax_done: function(response) {
    this.popover_cache[response.document_number] = response;
    if( this.current_el.data('document-number') === response.document_number ) {
      this.add_popover_content();
    }
  }
};

