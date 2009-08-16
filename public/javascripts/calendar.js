$(document).ready(function(){

  /* showing the first list of dates in month */
  first_date = $('.dayWithEvents a').get(0);
  show_date(first_date);
  
  $('.dayWithEvents a').bind('click', function() {
    hide_dates();
    show_date(this);
  });
  
  /* showing the hidden extra entries on a given day */
  $('.more a').live('click', function(){
    show_extra_entries(this);
    change_link(this);
    $(this).text('hide extra');
    return false;
  });
  $('.less a').live('click', function(){
    hide_extra_entries(this);
    change_link(this);
    $(this).text('view all');
    return false;
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

function hide_extra_entries(el) {
  id = '#' + $(el).attr('href').replace(/.*#/, '')
  $(id).hide();
}

function show_extra_entries(el) {
  id = '#' + $(el).attr('href').replace(/.*#/, '')
  $(id).show();
}

function change_link(el) {
  $(el).closest('span').toggleClass('more');
  $(el).closest('span').toggleClass('less')
}