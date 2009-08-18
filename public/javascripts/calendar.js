$(document).ready(function(){

  if( $('.dayWithEvents a').get(0) ) {
    /* showing the first list of dates in month */
    first_date = $('.dayWithEvents a').get(0);
    show_date(first_date);
  }
  
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
  
  /* adding ajax to calendar for the entries page */
  $('.dayWithEntries a').bind('click', function() {
    rewrite_url(this);
    return false;
  });
  
  $('.precolumn .header a.icon.cal').bind('click', function() {
    $('div.entry_calendars').toggle();
    return false;
  });
  
  show_calendars = window.location.href.replace(/.*\?show_calendars=/, '');
  show_calendars = show_calendars.replace(/\&.*/, '')
  if(show_calendars == 'true') {
    $('div.entry_calendars').show();
  }
});

function hide_dates() {
  $('.calendar_date').each(function(){
    $(this).hide();
  });
}

function show_date(el) {
  id = $(el).attr('href').replace(/.*#event_/, '');
  date_to_show = $('#date_'+id);
  date_to_show.show();
}

function hide_extra_entries(el) {
  id = '#' + $(el).attr('href').replace(/.*#/, '');
  $(id).hide();
}

function show_extra_entries(el) {
  id = '#' + $(el).attr('href').replace(/.*#/, '');
  $(id).show();
}

function change_link(el) {
  $(el).closest('span').toggleClass('more');
  $(el).closest('span').toggleClass('less');
}

function rewrite_url(el) {
  date = $(el).attr('href').replace(/.*#entry_/, '');
  console.log(date);
  window.location.href = '/entries/'+date;
}