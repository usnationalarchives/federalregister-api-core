var SpellChecker = (function(){
  var SpellChecker = function() {
  };

  SpellChecker.prototype = {
    initialize: function(options) {
      this.element_class = options.element_class || 'body';
      this.spelling_class = options.spelling_class || '.spelling_error';
      this.open_behaviour = options.open_behaviour || 'mouseenter';
      this.close_behaviour = options.close_behaviour || 'mouseleave';
      this.handlebars_template = options.handlebars_template || '#spelling-error-menu-template';

      this.template = Handlebars.compile( $(this.handlebars_template).html() );

      this.add_behaviour();
    },

    add_behaviour: function() {
      var spell_checker = this;
      $(this.element_class).on(this.open_behaviour, this.spelling_class, function(event) {
        event.stopPropagation();
        event.preventDefault();
        
        spell_checker.active_element = $(this);
        spell_checker.active_element_text = spell_checker.active_element.text();
        spell_checker.show_menu();
      });

      $(this.element_class).on(this.close_behaviour, this.spelling_class, function(event) {
        spell_checker.remove_menu();
      });
    },

    show_menu: function() {
      this.create_menu();
      this.menu.css({left: this.active_element.position().left, 
                     top: this.active_element.position.top + 10});
      this.active_element.append( this.menu );
    },

    create_menu: function() {
      var spell_checker = this;

      spell_checker.menu = $(this.template( {suggestions: this.active_element.data('suggestions')} ) );
      
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

    remove_menu: function() {
      this.menu.remove();
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
      this.menu.remove();
    },

    remove_highlight_via_add_to_dictionary: function() {
      var word = this.active_element.data('misspelled-word');

      $('.spelling_error[data-misspelled-word=' + word + ']').removeClass('spelling_error');
      this.menu.remove();
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
