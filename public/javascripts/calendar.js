$(document).ready(function(){
  $('table.calendar .nav').live('click', function() {
    $('#calendar_wrapper').load($(this).attr('href'));
    return false;
  });
  
  $('#date_selector').submit(function(){
    var form = $(this);
    var path = $(this).attr('action');
    $.ajax({
      url: path,
      data: {'search' : $(form).find('#search').val()},
      complete: function(xmlHttp) {
        var status = xmlHttp.status;
        form.find('span.error').remove();
        if (status == '200') {
          window.location = xmlHttp.responseText;
        } else if (status == '422' || status == '404' ) {
          form.append($("<span class='error'></span>").text(xmlHttp.responseText))
        } else {
          form.append("<span class='error'><strong>Unknown error.</strong></span>")
        }
      }
    });
    return false;
  })
});