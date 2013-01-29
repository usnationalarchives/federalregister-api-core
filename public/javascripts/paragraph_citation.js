Handlebars.registerHelper('escape_string', function(string) {
  return new Handlebars.SafeString(
    escape(string)
  );
});

$(document).ready(function () {
    var paragraph_citation_box_template;
    if ( $("#paragraph-citation-box-template").length > 0 ) {
      paragraph_citation_box_template = Handlebars.compile($("#paragraph-citation-box-template").html());
    }

    var citation_box_timeout = null,
        citation_marker_timeout = null;

    var citation_box = {
      anchor: $("<span>").addClass('trigger').html("Show citation box"), //"<span class='trigger'>Show citation box</span>",
      document_information: {
                              document_number: $(".doc_number").text(),
                              volume: $(".metadata_list .volume").text(),
                              title: document.title
                            },

      cache: {},

      create: function(paragraph_id) {
                /* only add the citation box to the DOM if it's not there already */
                if ($('#paragraph-citation-box').size() === 0) {
                    $('#fulltext_content_area').append( $('<div>').attr('id', "paragraph-citation-box") );
                }
                
                var self = this;
                /* gather info for citation box */
                var id = "citation_info_" + paragraph_id;
                var index_el = $("#" + paragraph_id);
                var next_header = index_el.nextAll(':header').add(index_el.parentsUntil('#content_area').nextAll().find(':header')).first();
                /* create object for handlebars */
                var paragraph_details = {
                      page: index_el.attr('data-page'),
                      document_information: self.document_information,
                      url: 'http://' + window.location.host + '/a/' + self.document_information.document_number + '/' + paragraph_id,
                      id: id,
                      content: index_el.text(),
                      next_header_text: next_header.text().replace(/ Back to Top/, ''),
                      next_header_anchor: next_header.attr('id')
                    };
                
                /* render the citation box from the template */
                return $('#paragraph-citation-box').html( paragraph_citation_box_template(paragraph_details) );
              },

      display: function(paragraph_id) {
                  var self = this;

                  /* create citation box or retrieve from cache */
                  var citation_box = null;
                  if (this.cache[paragraph_id] === undefined) {
                    citation_box = self.create(paragraph_id);
                    this.cache[paragraph_id] = citation_box.clone();
                  } else {
                    citation_box = this.cache[paragraph_id].clone();
                  }

                  /* add citation box to DOM */
                  $("#sidebar").append(citation_box);

                  var citation_el = citation_box.find('.citation_box');//$("#citation_info_" + paragraph_id);
                  var paragraph_el = $("#" + paragraph_id);

                  /* position citation box in relation to it's cooresponding paragraph */
                  citation_el.css({
                      "top": paragraph_el.position().top + 6,
                      "right": 37,
                      "display": "block"
                    }).data("id", paragraph_id);

                  citation_el.fadeIn(100);

                  /* close citation box after 0.5 seconds */
                  citation_el.bind('mouseleave', function(event) {
                    var citation = $(this);
                    citation_box_timeout =  setTimeout( function() {
                                              self.hide(citation);
                                            }, 500);
                  });

                  citation_el.bind('mouseenter', function(event) {
                    clearTimeout( citation_box_timeout );
                  });
               },

      hide: function(citation_info) {
        citation_info.fadeOut(300, function() {
          citation_info.remove();
        });
      }
    };

    $('#fulltext_content_area').delegate("*[id^='p-']", 'mouseenter', function(event) {
      clearTimeout( citation_marker_timeout );
      clearTimeout( citation_box_timeout );

      $('#fulltext_content_area').find('.trigger').remove();
      citation_box.hide( $('#paragraph-citation-box') );

      var el = $(this);
      var paragraph_id = el.attr('id');

      if( el.find('.trigger').length === 0 ) {
        var anchor = $(citation_box.anchor);

        anchor.data('paragraph_id', paragraph_id);
        el.append( anchor );
        
        anchor.css({
          "top": el.position().top + 6,
          "right": -5,
          "display": "block"
        });

        anchor.bind('mouseenter', function(event) {
          var trigger = $(this);
          trigger.fadeOut(100, function() {
            citation_box.display( paragraph_id );
            trigger.remove();
          });
        });

      }
    });

    $('#fulltext_content_area').delegate(".body_column *[id^='p-'], .body_column ul > li[id^='p-'], .reg_text *[id^='p-']", 'mouseleave', function(event) {
      var el = $(this);
      var trigger = el.find('.trigger');
      citation_marker_timeout = setTimeout( function() {
                                  trigger.fadeOut(100, function() {
                                    trigger.remove();
                                  });
                                }, 700);
    });

    $(".citation_box li.next a, .citation_box li.top a").live('click', function(event) {
      event.preventDefault();
      var el_id = $(this).attr('href');
      var target_el = $("#fulltext_content_area").find( el_id );

      /* scroll to the paragraph past the header if it is one that can be cited ,
       * these allows the reader to see past the header and not need to scroll again immediately */
      var next_after_target = target_el.next();
      var scroll_target = target_el;
      if( next_after_target.length > 0 && next_after_target.attr('id').match(/^p-/) !== null ) {
        scroll_target = next_after_target;
      }

      /* scroll target into view, highlight, and update window has so that the back button works */
      scroll_target.scrollintoview({
        duration: 200,
        complete: function() {
          target_el.effect("highlight", {color: "#d2eff9"}, 1500);
          window.location.hash = el_id;
        }
      });
    });
});
