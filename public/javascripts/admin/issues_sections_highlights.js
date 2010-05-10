$(document).ready(function(){
  var base_url = window.location;
  $('dt:not(.highlighted)').live('click', function(){
    var entry = $(this);
    $.ajax({
      url: base_url + '/highlights',
      type: 'POST',
      data: "section_highlight[entry_id]=" + $(this).attr('data-entry-id'),
      success: function(response) {
        entry.addClass('highlighted');
      }
    })
  });
  $("ul#highlighted .remove").live('click', function() {
    var item = $(this).parent();
    var entry_id = item.attr('data-entry-id');
    $.ajax({
      url: base_url + '/highlights/' + entry_id,
      type: 'DELETE',
      data: '',
      success: function() {
        item.remove();
        $('dt[data-entry-id=' + entry_id + ']').removeClass('highlighted');
      }
    });
  });
  $("ul#highlighted").sortable({
    stop: function(event, ui) {
      var entry_id = ui.item.attr('data-entry-id');
      var position = ui.item.prevAll('li').size() + 1;
      $.ajax({
        url: base_url + '/highlights/' + entry_id,
        type: 'PUT',
        data: "section_highlight[new_position]=" + position,
        success: function() {
          entry.addClass('highlighted');
        }
      })
    }
  });
});