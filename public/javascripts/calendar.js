$(document).ready(function () {
    function add_year_dropdown() {
        var th = $('table.calendar .monthName');

        // only create/append the year select if there isn't one
        if ( th.children('select').length === 0 && ! th.closest('table.calendar').hasClass('no_select') ) {
          var select_list = $("<select />");
          var today = new Date();
          var start_year = parseInt( $('table.calendar').data('year-start'), 10 );
          var end_year   = parseInt( $('table.calendar').data('year-end'), 10 );

          // don't create a year select if the data doesn't span years
          if (end_year > start_year) {
            for(var year = start_year; year <= end_year; year++) {
                var option = $("<option />");
                option.append(year);
                if ( parseInt($(".calendar").attr("data-calendar-year"), 10) === year ) {
                    option.attr('selected', 'selected');
                }
                select_list.append(option);
            }
            th.append(select_list);
          }
        }
    }
    
    add_year_dropdown();
    
    $('table.calendar .nav').live('click', function (event) {
        event.stopPropagation();
        event.preventDefault();
       
        var nav_item = $(this);
        var cal =  nav_item.closest('table.calendar');
        var cal_wrapper = cal.closest('#calendar_wrapper');

        var href = nav_item.attr('href');
        if( cal.hasClass('no_select') ) {
          href = href + '?table_class=no_select';
        }
               
        var xhr_requests = [];
        if( cal_wrapper.hasClass('cal_double') ) {
          var direction = cal.hasClass('cal_first') ? 'backward' : 'forward';

          $.each( cal_wrapper.find('table'), function(index, el) {

            // we're swapping out two calendars at once while clicking on only one
            // we figure out the direction in time the user wants the calendars to be changed
            // then we set the other calendar to the clicked calendar's url so that it seems to have just 'moved over'.
            if( direction === 'backward' ) {
              if( $(el).hasClass('cal_first') ) {
                href = nav_item.attr('href') + '?table_class=no_select cal_first';
              } else {
                href = '/articles/' + $('table.cal_first').data('calendar-year') + '/' + $('table.cal_first').data('calendar-month') + '?table_class=no_select cal_last';
              }
            } else {
              if( $(el).hasClass('cal_first') ) {
                href = '/articles/' + $('table.cal_last').data('calendar-year') + '/' + $('table.cal_last').data('calendar-month') + '?table_class=no_select cal_first';
              } else {
                href = nav_item.attr('href') + '?table_class=no_select cal_last';
              }
            }

            // queue up the ajax requests so that we can fire them together in a 'when' block
            xhr_requests[index] = [href, $(el)];
          });

          // fire both requests and wait until we get responses from both before updating the UI.
          $.when( $.ajax({ url: xhr_requests[0][0] }), $.ajax({ url: xhr_requests[1][0] }) ).done( function(response1, response2) {
            xhr_requests[0][1].replaceWith(response1[0]);
            xhr_requests[1][1].replaceWith(response2[0]);

            add_year_dropdown();
            if( cal_wrapper.hasClass('cal_double') ) {
              $('#navigation .previewable table.cal_first').find('.cal_next').html('');
              $('#navigation .previewable table.cal_last').find('.cal_prev').html('');
            }
          });
          
       } else {
          cal_wrapper.load(href, '', add_year_dropdown);
       }
    });

    $("#date_chooser").delegate('select', 'change', function(event) {
      event.stopPropagation();
      event.preventDefault();

      $('#calendar_wrapper').load('/articles/' + $(this).val() + '/' + $(".calendar").attr("data-calendar-month"),'', add_year_dropdown);
    });

        
    $('.calendar td.late').live('click', function() {
      window.alert("Today's issue is currently unavailable; we apologize for any inconvenience.");
    });
    
    $('#date_selector').submit(function () {
        var form = $(this);
        var path = $(this).attr('action');
        $.ajax({
            url: path,
            data: {
                'search': $(form).find('#search').val()
            },
            complete: function (xmlHttp) {
                var status = xmlHttp.status;
                form.find('span.error').remove();
                if (status === 200) {
                    window.location = xmlHttp.responseText;
                } else if (status === 422 || status === 404) {
                    form.append($("<span class='error'></span>").text(xmlHttp.responseText));
                } else {
                    form.append("<span class='error'><strong>Unknown error.</strong></span>");
                }
            }
        });
        return false;
    });
});
