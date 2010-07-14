$(document).ready(function(){
  $('table.calendar .nav').live('click', function() {
    $('table.calendar').load($(this).attr('href'));
    return false;
  });
});