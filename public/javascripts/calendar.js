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
        
        href = $(this).attr('href');
        if( $(this).closest('table.calendar').hasClass('no_select') ) {
          href = href + '?table_class=no_select';
        }
        console.log( $(this), $(this).closest('table.calendar'), href );
        $('#calendar_wrapper').load(href, '', add_year_dropdown);
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
