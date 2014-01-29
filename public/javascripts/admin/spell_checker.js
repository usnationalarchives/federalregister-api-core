/*global SpellChecker:true */
var SpellChecker = (function(){
  var SpellChecker = function() {
    this.ajax_suggestions = false;
  };

  SpellChecker.prototype = {
    initialize: function(options) {
      this.element_class = options.element_class || 'body';
      this.spelling_class = options.spelling_class || '.spelling_error';
      this.open_behaviour = options.open_behaviour || 'mouseenter';
      this.close_behaviour = options.close_behaviour || 'mouseleave';
      this.open_behavior_delay = options.open_behavior_delay || 1;
      this.handlebars_template = options.handlebars_template || '#spelling-error-menu-template';
      this.handlebars_loading_template = options.handlebars_loading_template || '#spelling-error-loading-menu-template';

      if( options.ajax_suggestions === true ) {
        this.ajax_suggestions = true;
        this.ajax_suggestion_url = options.ajax_suggestion_url || 'not-implemented';
      }

      this.suggestion_cache = {};
      this.suggestionDeferreds = {};

      this.template = Handlebars.compile( $(this.handlebars_template).html() );
      this.loading_template = Handlebars.compile( $(this.handlebars_loading_template).html() );

      this.add_behaviour();
    },

    add_behaviour: function() {
      var spell_checker = this;

      $(this.element_class).on(this.open_behaviour, this.spelling_class, function(event) {
        event.stopPropagation();
        event.preventDefault();

        var $current_el = $(this);

        spell_checker.timeout = setTimeout(function() {
          spell_checker.active_element = $current_el;
          spell_checker.active_element_text = spell_checker.active_element.data('misspelled-word');
          spell_checker.show_menu();
        }, spell_checker.open_behavior_delay);
      });

      $(this.element_class).on(this.close_behaviour, this.spelling_class + ' .spelling_error_menu:not(.loading)', function(event) {
        clearTimeout(spell_checker.timeout);

        spell_checker.remove_menu($(this));
        spell_checker.remove_menu(spell_checker.loading_menu);
        spell_checker.suggestionDeferreds[spell_checker.active_element.data('misspelled-word')].reject();
      });

      $(this.element_class).on(this.close_behaviour, this.spelling_class, function(event) {
        clearTimeout(spell_checker.timeout);
        $(this).find('.spelling_error_menu').not('.loading').trigger(spell_checker.close_behaviour);
      });
    },

    get_suggestions: function() {
      var spellChecker = this;

      if( spellChecker.ajax_suggestions ) {
        var misspelled_word;
        if( spellChecker.active_element.data('misspelled-word') ) {
          misspelled_word = spellChecker.active_element.data('misspelled-word');
        } else {
          misspelled_word = spellChecker.active_element.text();
        }

        if( ! spellChecker.suggestion_cache[misspelled_word] ) {
          $.ajax({
            type: "GET",
            url: spellChecker.ajax_suggestion_url,
            data: {word: misspelled_word},
            dataType: 'json',
            success: function(response) {
              spellChecker.suggestion_cache[misspelled_word] = response.suggestions;
              spellChecker.suggestions = response.suggestions;
              spellChecker.suggestionDeferreds[misspelled_word].resolve();
            }
          });
        } else {
          spellChecker.suggestions = spellChecker.suggestion_cache[misspelled_word];
          spellChecker.suggestionDeferreds[misspelled_word].resolve();
        }
      } else {
        spellChecker.suggestions = spellChecker.active_element.data('suggestions');
        spellChecker.suggestionDeferred.resolve();
      }
    },

    show_menu: function() {
      var spellChecker = this;

      if( spellChecker.ajax_suggestions ) {
        spellChecker.create_loading_menu();
        spellChecker.position_menu(spellChecker.loading_menu);
      }

      var currently_misspelled_word = spellChecker.active_element.data('misspelled-word');
      spellChecker.suggestionDeferreds[currently_misspelled_word] = $.Deferred();
      $.when(spellChecker.suggestionDeferreds[currently_misspelled_word]).done(function() {
        if( spellChecker.active_element.find('.spelling_error_menu').not('.loading').length === 0 ) {
          spellChecker.create_menu();
          spellChecker.position_menu(spellChecker.menu);
        }
        spellChecker.remove_menu(spellChecker.loading_menu);
      });
      spellChecker.get_suggestions();
    },

    position_menu: function(menu) {
      menu.css({left: this.active_element.position().left,
                top: this.active_element.position.top + 10});
      this.active_element.append( menu );
    },

    create_loading_menu: function() {
      this.loading_menu =  $(this.loading_template());
    },

    create_menu: function() {
      var spell_checker = this;

      spell_checker.menu = $(this.template( {suggestions: this.suggestions} ) );

      spell_checker.menu.on('mouseenter', 'li', function(event) {
        $(this).addClass('hover');
      });

      spell_checker.menu.on('mouseleave', 'li', function(event) {
        $(this).removeClass('hover');
      });

      spell_checker.menu.on('click', 'li', function(event) {
        event.preventDefault();
        event.stopPropagation();

        var clicked_el = $(this);

        clicked_el.addClass('saving');

        if( clicked_el.data('role') === 'add-to-dictionary' ) {
          clicked_el.unbind('click');
          spell_checker.add_to_dictionary( spell_checker.active_element, spell_checker.active_element_text );
        } else if( clicked_el.data('role') === 'replace-word' ) {
          spell_checker.correct_word = clicked_el.text();
          spell_checker.replace_word();
        }
      });
    },

    remove_menu: function(menu) {
      if( menu !== undefined ) {
        menu.remove();
      }
    },

    replace_word: function() {
      /* set correct word and then get complete correct string for submission */
      this.active_element.text( this.correct_word );
      var new_title = this.active_element.closest('span.title').text().trim();

      /* change text back to original so user only sees corrected version state when it is set later */
      this.active_element.text( this.active_element.data('misspelled-word') );

      this.submit_replacement(this.active_element, new_title);
    },

    remove_highlight_via_correction: function() {
      this.active_element.removeClass('spelling_error');

      this.remove_menu(this.menu);
    },

    remove_highlight_via_add_to_dictionary: function() {
      var word = this.active_element.data('misspelled-word');

      $('.spelling_error[data-misspelled-word=' + word + ']').removeClass('spelling_error');
      this.remove_menu(this.menu);
    },

    submit_replacement: function(active_element, replacement) {
      alert("This is a stub method and should be implemented by adding it to your instance of spellchecker \n function: submit_replacement(active_element, replacement)");
    },

    add_to_dictionary: function(active_element, word_to_add) {
      alert("This is a stub method and should be implemented by adding it to your instance of spellchecker \n function: add_to_dictionary(active_element, word_to_add)");
    }
  };

  return SpellChecker;
})();
