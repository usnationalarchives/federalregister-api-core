$(document).ready(function(){
  hide_dates();
  first_date = $('.dayWithEvents a').get(0);
  show_date(first_date);
  
  $('.dayWithEvents a').bind('click', function() {
    hide_dates();
    show_date(this);
  });
});

function hide_dates() {
  $('.calendar_date').each(function(){
    $(this).hide();
  });
}

function show_date(el) {
  id = $(el).attr('href').replace(/.*#event_/, '')
  date_to_show = $('#date_'+id);
  date_to_show.show();
}