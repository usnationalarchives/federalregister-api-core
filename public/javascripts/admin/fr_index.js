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
fr_index_popover_handler.fields = 'fields%5B%5D=toc_subject&fields%5B%5D=toc_doc&fields%5B%5D=document_number';
fr_index_popover_handler.add_popover_content = function() {
    var $tipsy_el = $('.tipsy'),
        prev_height = $tipsy_el.height(),
        fr_index_entry_popover_content_template = Handlebars.compile($("#fr-index-entry-popover-content-template").html()),
        popover_id = '#popover-' + this.current_el.data('document-number'),
        new_html = fr_index_entry_popover_content_template( this.popover_cache[this.current_el.data('document-number')] );

    $(popover_id).find('.loading').replaceWith( new_html );
  };


var FRIndexEditorForm = (function() {
  try {
    var FRIndexEditorForm = function() {
      this.form_template = Handlebars.compile($("#fr-index-form-template").html());
    };

    FRIndexEditorForm.prototype = {
      initialize: function(fr_index_editor_instance, form_data) {
        this.form = $(this.form_template( form_data ));
        this.editor_instance = fr_index_editor_instance;

        this.add_field_tooltips();
        this.add_autocompleter();
        this.add_submit_handler();


        return this.form;
      },

      add_field_tooltips: function() {
        var fr_subject_input = this.form.find('.fr_index_subject');

        fr_subject_input.tipsy({  opacity: 1.0,
                                  gravity: 'e',
                                  fallback: 'Category',
                                  trigger: 'manual' });

        var fr_doc_input = this.form.find('.fr_index_doc');

        fr_doc_input.tipsy({ opacity: 1.0,
                             gravity: 'e',
                             fallback: 'Subject Line',
                             trigger: 'manual'});


        var inputs = this.form.find('.fr_index_subject, .fr_index_doc');

        inputs.on('focus', function(event) {
          var $input = $(this),
              tipsy_right_adjustment = $input.hasClass('fr_index_subject') ? 30 : 0;

          $input.tipsy('show');
          $('.tipsy').addClass('input_tipsy').css('left', $input.position().left - $('.tipsy').width() - tipsy_right_adjustment);
          $('.tipsy .tipsy-arrow').css('right', -16);
        });

        inputs.on('blur', function(event) {
          $(this).tipsy('hide');
        });
      },

      add_autocompleter: function() {
        this.form.find('.fr_index_subject').typeahead({
          minLength: 3,
          source: this.editor_instance.current_toc_subjects
        });

        this.form.find('.fr_index_doc').typeahead({
          minLength: 3,
          source: this.editor_instance.current_toc_docs
        });
      },

      add_submit_handler: function() {
        var frIndexEditorForm = this;

        this.form.on('submit', function(event) {
          event.preventDefault();
          var form = $(this);

          frIndexEditorForm.identify_as_saving();
          frIndexEditorForm.submit_form();
        });
      },

      submit_form: function() {
        var frIndexEditorForm = this,
            path = this.form.attr('action'),
            data = this.form.serialize();

        /* set active form so that response can be handled by the editor
         * instance that spawned the form */
        frIndexEditorForm.editor_instance.active_form = this.form;

        $.ajax({
          url: path,
          data: data,
          type: 'PUT',
          dataType: 'json',
          success: function(response) {
            frIndexEditorForm.editor_instance.form_ajax_success(response);
          }
        });
      },

      identify_as_saving: function() {
        var submit_button = this.form.find('input[type=submit]').first();

        this.form.addClass('disabled');
        this.form.siblings('a.cancel').hide();
        submit_button.val('Saving');
        submit_button.attr("disabled", true);
      }
    };

    return FRIndexEditorForm;
  } catch(e) {
    Honeybadger.notify(e);
  }
})();

var FRIndexEditor = (function(){
  try {
    var FRIndexEditor = function() {
      this.form_object = new FRIndexEditorForm();
      /* active form is set on submit by the form object */
      this.active_form = null;
    };

    FRIndexEditor.prototype = {
      initialize: function(elements) {
        this.elements = elements;
        this.wrappers = this.elements.find('a.wrapper');
        this.edit_buttons = this.elements.find('a.edit');
        this.setup();
      },

      setup: function() {
        this.add_wrapper_toggle();
        this.add_edit_context_highlight();
        this.generate_toc_subject_and_doc_autocompleter_elements();
        this.add_edit_funtionality();
      },

      add_wrapper_toggle: function() {
        this.wrappers.off('click');

        this.wrappers.on('click', function(event) {
          event.preventDefault();
          $(this).siblings('ul.entry_details').toggle();
        });
      },

      add_edit_context_highlight: function() {
        this.edit_buttons.off('hover');

        this.edit_buttons.on('hover', function(event) {
          var context_wrapper = $(this).closest('li');

          if( event.type === 'mouseleave' ) {
            context_wrapper.removeClass('hover');
          } else {
            context_wrapper.addClass('hover');
          }
        });
      },

      generate_toc_subject_and_doc_autocompleter_elements: function() {
        this.current_toc_subjects = $('#current_toc_subjects').data('values');
        this.current_toc_docs = $('#current_toc_docs').data('values');
      },

      add_edit_funtionality: function() {
        var frIndexEditor = this;

        /* ensure buttons are in clean state */
        this.edit_buttons.off('click');

        this.edit_buttons.on('click', function(event) {
          event.preventDefault();
          var edit_button = $(this),
              context_wrapper = edit_button.closest('li');

          frIndexEditor.highlight_edit_context( context_wrapper );
          frIndexEditor.close_parent_form( context_wrapper );
          frIndexEditor.convert_to_cancel_button( edit_button );
          frIndexEditor.display_form( context_wrapper );
        });
      },

      close_parent_form: function(context_wrapper) {
        var frIndexEditor = this,
            top_level_form = null;

        if( ! context_wrapper.hasClass('top_level') ) {
          top_level_form = context_wrapper.
                                closest('ul').
                                closest('li').
                                find('form.top_level').
                                first();

          var top_level_wrapper_context = top_level_form.closest('li');

          top_level_form.remove();

          top_level_wrapper_context.removeClass('edit');
          frIndexEditor.convert_to_edit_button( top_level_wrapper_context.find('a.cancel').first(), frIndexEditor);
        }
      },

      convert_to_cancel_button: function(edit_button) {
        var frIndexEditor = this;

        edit_button.removeClass('edit').addClass('cancel').html('Cancel');
        edit_button.off('click');

        edit_button.on('click', function(event) {
          event.preventDefault();
          frIndexEditor.convert_to_edit_button( $(this), frIndexEditor );
        });
      },

      convert_to_edit_button: function(edit_button, frIndexEditor) {
        var context_wrapper = edit_button.closest('li');

        edit_button.removeClass('cancel').addClass('edit').html('Edit');
        context_wrapper.find('form').remove();
        context_wrapper.removeClass('edit').addClass('hover');

        frIndexEditor.add_edit_funtionality();
      },

      highlight_edit_context: function(context_wrapper) {
        context_wrapper.addClass('edit');
        context_wrapper.removeClass('hover');
      },

      display_form: function(context_wrapper) {
        var frIndexEditor = this,
            form_data = context_wrapper.data('form-data'),
            form = this.form_object.initialize(frIndexEditor, form_data);

        form.insertAfter( context_wrapper.find('a.cancel').first() );

        /* ensure all of form is visible and place cursor in first input */
        form.find('input[type!=hidden]').last().scrollintoview();
        form.find('input[type!=hidden]').first().focus();
      },

      form_ajax_success: function(response) {
        /* clear form tooltips before removing or they hang out orphaned */
        this.active_form.find('input[type=text]').trigger('blur');

        var wrapping_list = this.active_form.closest('ul.entry_type'),
            wrapping_context = this.active_form.closest('li');

        this.remove_items_in_context( wrapping_context );
        this.remove_modified_item( response.id_to_remove );

        this.insert_alphabetically( response.element_to_insert, response.header, wrapping_list );

        this.initialize( $('#content_area ul.entry_type > li') );

      },

      /* we need to remove the appropriate context because an edit can effect
       * multiple items on the page */
      remove_items_in_context: function(wrapping_context) {
        if ( ! wrapping_context.hasClass('top_level') ) {
          var context_siblings = wrapping_context.siblings('li');

          if (context_siblings.size() === 0) {
            wrapping_context.closest('li.top_level').remove();
          }
          else if (context_siblings.size() === 1) {
            wrapping_context.closest('li.top_level').children('.edit').remove();
            wrapping_context.remove();
          }
        } else {
          wrapping_context.remove();
        }
      },

      remove_modified_item: function(id) {
        $('#' + id).remove();
      },

      insert_alphabetically: function(element, header, wrapping_list) {
        var added_element = null;
        wrapping_list.children('li').each(function() {
          var list_item = $(this);
          if (list_item.find('span.title:first').text().trim() > header) {
            added_element = $(element).insertBefore(list_item);
            return false;
          }
        });

        // if not already added ahead of an existing element, append it to the end
        if ( ! added_element ) {
          added_element = $(element).appendTo(wrapping_list);
        }

        this.highlight_added_element(added_element);
      },

      highlight_added_element: function(element) {
        element.scrollintoview({
          duration: 300,
          complete: function() {
            element.effect("highlight", {color: '#e5edef'}, 2000);
          }
        });
      },

      silent_spelling_correction_submit: function(context_wrapper, header_attribute, text) {
        var form_data = context_wrapper.data('form-data'),
            frIndexEditor = this;

        form_data[header_attribute] = text;

        var form = this.form_object.initialize(frIndexEditor, form_data);

        context_wrapper.append( form.hide() );
        form.submit();
      }
    };

    return FRIndexEditor;
  } catch(e) {
    Honeybadger.notify(e);
  }
})();


$(document).ready(function() {
  try {
    //initializeFrIndexEditor($('#content_area ul.entry_type > li'));
    var frIndexEditor = new FRIndexEditor();
    frIndexEditor.initialize( $('#content_area ul.entry_type > li') );

    var spellChecker = new SpellChecker();
    spellChecker.initialize({element_class: "ul.entry_type",
                             ajax_suggestions: true,
                             ajax_suggestion_url: '/admin/spelling_suggestions',
                             open_behavior_delay: 500});

    spellChecker.add_to_dictionary = function(active_element, word_to_add) {
      $.ajax({
        type: "POST",
        url: '/admin/dictionary_words',
        data: {word: word_to_add},
        success: function(response) {
          spellChecker.remove_highlight_via_add_to_dictionary();
        }
      });
    };

    spellChecker.submit_replacement = function(active_element, replacement) {
      var fr_index_li = $(active_element).closest('li'),
          header_attribute = $(active_element).closest('span.title').data('header-attribute');

      frIndexEditor.silent_spelling_correction_submit(fr_index_li, header_attribute, replacement);
    };

    var popover_handler = fr_index_popover_handler.initialize();
    if ( $("#fr-index-entry-popover-template") !== []) {
      var fr_index_entry_popover_template = Handlebars.compile($("#fr-index-entry-popover-template").html());

      $('body').delegate('.with_ajax_popover a.document_number', 'mouseenter', function(event) {
        var $el = $(this),
            $li = $el.closest('.with_ajax_popover');


        /* add tipsy to the element */
        $el.tipsy({ fade: true,
                    opacity: 1.0,
                    gravity: 'n',
                    offset: 5,
                    html: true,
                    title: function(){
                      return fr_index_entry_popover_template( {content: new Handlebars.SafeString('<div class="loading">Loading...</div>'),
                                                               document_number: $li.data('document-number'),
                                                               title: 'Original ToC Data'} );
                    }
                  });
        /* trigger the show or else it won't be shown until the next mouseover */
        $el.tipsy("show");
        $('.tipsy.tipsy-n').addClass('popover');

        /* get the ajax content and show it
         * this used to be bound to the li - so we pass it through here
         * to stay consistent with other uses of the handler */
        popover_handler.get_popover_content( $li );
      });
    }

    $('#indexes.admin form.max_date select#max_date').on('change', function(event) {
      $(this).closest('form').submit();
    });
  } catch(e) {
    Honeybadger.notify(e);
  }
});
