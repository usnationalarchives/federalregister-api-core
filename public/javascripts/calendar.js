$(document).ready(function () {
    function add_year_dropdown() {
        var th = $('table.calendar .monthName');
        console.log(th);
        
        var select_list = $("<select />");
        var today = new Date();
        for(var year = 1994; year <= today.getFullYear(); year++) {
            var option = $("<option />");
            option.append(year);
            
            if (th.hasClass('year_' + year)) {
                option.attr('selected', 'selected');
            }
            select_list.append(option);
        }
        th.append(select_list);
    }
    
    add_year_dropdown();
    
    $('table.calendar .nav').live('click', function () {
        $('#calendar_wrapper').load($(this).attr('href'), '', add_year_dropdown);
        return false;
    });
    
    $('.calendar td.late').live('click', function() {
        alert("Today's issue is currently unavailable; we apologize for any inconvenience.")
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
                if (status == '200') {
                    window.location = xmlHttp.responseText;
                } else if (status == '422' || status == '404') {
                    form.append($("<span class='error'></span>").text(xmlHttp.responseText));
                } else {
                    form.append("<span class='error'><strong>Unknown error.</strong></span>");
                }
            }
        });
        return false;
    });
});