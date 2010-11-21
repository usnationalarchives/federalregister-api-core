$(document).ready(function () {
    var populate_expected_results = function (count) {
        $('#expected_result_count').text(count);
    }
    
    var indicate_loading = function() {
        $('#expected_result_count').text('loading');
    }
    
    // ajax-y lookup of number of expected results
    var calculate_expected_results = function () {
        var form = $('#entry_search_form');
        var url = '/articles/search/results.js?' + form.serialize();
        
        var cache = form.data('count_cache') || {};
        
        // don't go back to the server if you've checked this before
        if (cache[url]) {
            populate_expected_results(cache[url])
        } else {
            // record that this is the current results we're looking for
            form.data('count_current_url', url);
            indicate_loading();
            
            $.getJSON(url, function(data){
                var form = $('#entry_search_form');
                var cache = form.data('count_cache') || {};
                cache[url] = data.count;
                form.data('count_cache', cache);
                
                // don't show number if user has already made another request
                if (form.data('count_current_url') == url) {
                    populate_expected_results(data.count);
                }
            });
        }
    };
    
    $('#entry_search_form select').blur(calculate_expected_results);
    $('#entry_search_form input[type=checkbox]').click(calculate_expected_results)
    // basic check for pause between events
    var typewatch = (function(){
      var timer = 0;
      return function(callback, ms){
        clearTimeout (timer);
        timer = setTimeout(callback, ms);
      }  
    })();
    $('#entry_search_form input[type=text]').keyup(function () {
        // only trigger if stopped typing for more than half a second
        typewatch(function () {
            calculate_expected_results();
        }, 500);
    });
    
    var display_rin_info = function(message) {
        var input = $('#conditions_regulation_id_number');
        
        input.siblings('.inline-hints').remove();
        
        if(message) {
            var node = $('<p class="inline-hints" />');
            node.text(message);
        
            input.after(node);
        }
    }
    
    var cache_rin_name = function (rin, name) {
        var input = $('#conditions_regulation_id_number');
        var cache = input.data('name_cache') || {};
        cache[rin] = name;
        input.data('name_cache', cache);
    }
    
    var load_rin_info = function() {
        var input = $('#conditions_regulation_id_number');
        var rin = input.val();
        
        if (rin.length == 9) {
            var cache = input.data('name_cache') || {};
            
            if (cache[rin]) {
                display_rin_info(cache[rin])
            }
            else {
                display_rin_info('loading');
            
                var url = '/regulations/' + rin + '.js';
                $.ajax({
                    url : url,
                    success : function(str) {
                        var data = $.parseJSON(str);
                        var name = data.name;
                        cache_rin_name(rin,name);
                        display_rin_info(name);
                    },
                    error : function() {
                        var name = 'Not in current Unified Agenda'
                        cache_rin_name(rin,name);
                        display_rin_info(name);
                    }
                });
            }
        }
        else {
            display_rin_info('');
        }
    }
    $('#conditions_regulation_id_number').blur(load_rin_info);
    $('#conditions_regulation_id_number').keyup(function () {
        // only trigger if stopped typing for more than half a second
        typewatch(function () {
            load_rin_info();
        }, 500);
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
            $('body').append([
              '<div id="modal">',
              '  <a href="#" class="jqmClose">Close</a>',
              '  <h3 class="title_bar">Loading...</h3>',
              '</div>'].join("\n")
            );
        });
    }

    $('#modal').centerScreen().jqm({
        ajax: '@href',
        ajaxText: 'Loading...',
        trigger: '.results a.add_to_calendar'
    });
});
