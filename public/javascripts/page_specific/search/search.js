$(document).ready(function () {
    var toggle_presdocu_types = function() {
      var type_checkboxes = $('.presidential_dependent');
      if ($('#conditions_type_presdocu').attr('checked')) {
        type_checkboxes.show().find(':input').removeAttr('disabled');
      }
      else {
        type_checkboxes.hide().find(':input').attr('disabled', 'disabled');
      }
    };

    $('#conditions_type_presdocu').bind('click', toggle_presdocu_types);
    toggle_presdocu_types();

    var populate_expected_results = function (text) {
        $('#expected_result_count').removeClass('loading');
        $('#expected_result_count').text(text).show();
    };
    
    var indicate_loading = function() {
        $('#expected_result_count').show().addClass('loading');
    };
    
    var get_current_url = function() {
        return '/articles/search/results.js?' + $("#entry_search_form :input[value!='']:not([data-show-field]):not('.text-placeholder')").serialize();
    };
    var requests = {};
    
    // ajax-y lookup of number of expected results
    var calculate_expected_results = function () {
        var form = $('#entry_search_form');
        var cache = form.data('count_cache') || {};
        var url = get_current_url();
        
        // don't go back to the server if you've checked this before
        if (cache[url] === undefined) {
            // record that this is the current results we're looking for
            form.data('count_current_url', url);
            indicate_loading();
            
            if( requests[url] === undefined ){
              requests[url] = url;
                      
              $.getJSON(url, function(data){
                  var form = $('#entry_search_form');
                  var cache = form.data('count_cache') || {};
                  cache[url] = data.message;
                  
                  requests[url] = undefined;
                  form.data('count_cache', cache);

                  // don't show number if user has already made another request
                  if (form.data('count_current_url') === url) {
                      populate_expected_results(cache[url]);
                  }
              });
            }
            
        } else {
            populate_expected_results(cache[url]);
        }
    };
    
    $('.result_set[data-expected-result-count]').each(function(){
        var text = $(this).attr('data-expected-result-count');
        
        var form = $('#entry_search_form');
        var cache = form.data('count_cache') || {};
        var url = get_current_url();
        cache[url] = text;
        form.data('count_cache', cache);
        populate_expected_results(text);
    });
    
    $('#entry_search_form').bind('calculate_expected_results', calculate_expected_results);
    
    $('#entry_search_form select, #entry_search_form input').bind('blur', function(event) {
      $(this).trigger('calculate_expected_results');
    });
    
    $('#entry_search_form input[type=checkbox]').bind('click', function(){
      $(this).trigger('calculate_expected_results');
    });
    
    // onchange doesn't trigger until blur, and onclick wasn't firing correctly either...
    //    so we poll for the current value. In FF, this fires when you hover over an
    //    item in the list, so it's a bit chatty, but seems ok.
    $('#entry_search_form select').bind('focus', function(){
        var elem = $(this);
        var callback = function() {
            elem.trigger('calculate_expected_results');
        };
        var poller = setInterval(callback, 250);
        $(this).data('poller', poller);
    });

    $('#entry_search_form select').bind('blur', function(){
        var poller = $(this).data('poller');
        clearInterval(poller);
        $(this).data('poller','');
    });
    
    // basic check for pause between events
    var typewatch = (function(){
      var timer = 0;
      return function(callback, ms){
        clearTimeout (timer);
        timer = setTimeout(callback, ms);
      };
    }());
    
    $('#entry_search_form input[type=text]').keyup(function () {
        // only trigger if stopped typing for more than half a second
        typewatch(function () {
            $("#entry_search_form").trigger('calculate_expected_results');
        }, 500);
    });
    
    $('.clear_form').click(function(){
        var form = $('#entry_search_form');
        form.find('input[type=text],input[type=hidden]').val('');
        form.find('input[type=radio],input[type=checkbox]').removeAttr('checked').change();
        form.find('select option:eq(0)').attr('selected','selected');
        form.find('#conditions_agency_ids option').remove();
        form.find('#conditions_within option:eq(3)').attr('selected','selected');
        $('#entry_search_form .bsmListItem').remove();
        $('#entry_search_form .date').hide().find("input").val('');
        $(this).trigger('calculate_expected_results');
        return false;
    });
    
    $('a.load_facet').live('click',
    function () {
        var anchor = $(this);
        $(this).after('<img src="/images/ui/ui-anim_basic_16x16.gif" />');
        var facet_name = anchor.attr('data-facet-name');
        var url = $(location).attr('href').replace('/search?', '/search/facets/' + facet_name + '?all=1&');
        $.ajax({
            url: url,
            success: function (data) {
                anchor.closest('ul').html(data);
            }
        });

        return false;
    });


    if ($(".result_set.events").size() > 0) {
        $('body#search.show').each(function () {
            var message = [
              '<div id="modal">',
              '  <a href="#" class="jqmClose">Close</a>',
              '  <h3 class="title_bar">Loading...</h3>',
              '</div>'].join("\n");
            $('body').append(message);
        });
    }

    $('#modal').jqm({
        ajax: '@href',
        ajaxText: 'Loading...',
        trigger: '.results a.add_to_calendar',
        onShow: modalOpen
    }).centerScreen();
    
    $(".date_options .date").hide();
    
    $("input[data-show-field]").bind('change', function(event) {
      var parent_fieldset = $(this).closest("fieldset");
      parent_fieldset.find(".date").hide().find(":input").disable(); 
      if ($(this).attr('checked')) {
          parent_fieldset.find("." + $(this).attr("data-show-field")).show().find(":input").enable();
      }
      $(this).trigger('calculate_expected_results');
    });
    $(".date_options input[data-show-field]:checked").trigger("change");
    
    // preselect date type radio button based on current values
    $("input[data-show-field]").each(function(){
        var type_radio_button = $(this);
        var parent_fieldset = type_radio_button.closest("fieldset");
        var matching_inputs = parent_fieldset.find("." + $(this).attr("data-show-field") + ' :input');
        
        matching_inputs.each(function(){
            if ($(this).val() !== '' && !$(this).hasClass('text-placeholder')) {
                type_radio_button.attr('checked', 'checked');
                type_radio_button.change();
            }
        });
    });
    
    //Add in some helpful hints that would be redundant if we had all the labels displaying
    $(".range_start input").after("<span> to </span>");
    $(".cfr li:first-child input").after("<span> CFR </span>");
    $(".zip li:first-child input").after("<span> within </span>");
    
    $(".formtastic select[multiple]").hide().bsmSelect({
      removeClass: 'remove'
    });
    
    $("#conditions_agency_ids").bind('change', function(event) {
      $(this).trigger('calculate_expected_results');
    });
    
    $("input[data-autocomplete]#article-agency-search").each(function(){
        var input = $(this);
        input.autocomplete({
        minLength: 3,
        source: function( request, response ){
          var elem = input;
          $.ajax({
            url: "/agencies/search?term=" + request.term,
            success: function(data){
              $(elem).removeClass("loading");
              response( 
                $.map( data, function( item ) {
                  return {
                    label: item.name,
                    value: item.name,
                    id: item.id
                  };
              }));	
            } // end success
          }); // end ajax
        },
        select: function( event, ui ) {
          $("#conditions_agency_ids").append("<option value=" + ui.item.id +" selected='selected'>" + ui.item.label + "</option>");
          $("#conditions_agency_ids").trigger("change");
          $(this).data('clear-value', 1);
        },
        close: function() {
          var input = $(this);
          if (input.data('clear-value')) {
             input.val('');
             input.data('clear-value',0);
          }
        },
        search: function( event, ui) {
          $(this).addClass("loading");
        }
      });
    });
    
    $("#toggle_advanced").bind('click', function(event) {
      event.preventDefault();
      if (location.hash === "#advanced") {
        location.hash = "";
      } else {
        location.hash = "#advanced";
      }
    });

    function toggleAdvanced(isOpen){
      var label = isOpen ? "Hide Advanced Search" : "Show Advanced Search";
      if (isOpen) {
        $(".advanced").addClass("open");
      } else {
        $(".advanced").removeClass("open");
      }
      $("#toggle_advanced").text(label).attr(label);
      $("#toggle_advanced").trigger('calculate_expected_results');
    }  

    $(window).bind('hashchange', function(){
      toggleAdvanced(location.hash === "#advanced");
    }).trigger('hashchange');
});
