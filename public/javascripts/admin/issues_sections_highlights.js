$(document).ready(function(){
  var base_url = window.location;
  $('article a.add').live('click', function(){
    var entry = $(this).closest('div.article');
    $(this).hide();
    $.ajax({
      url: base_url + '/highlights',
      type: 'POST',
      data: "section_highlight[entry_id]=" + entry.attr('data-entry-id'),
      success: function(response) {
        entry.addClass('highlighted');
      }
    });
  });
  $("ul#highlighted .remove").live('click', function() {
    var item = $(this).parent();
    var entry_id = item.attr('data-entry-id');
    if (confirm('Are you sure you wish to no longer highlight this document?')) {
      $.ajax({
        url: base_url + '/highlights/' + entry_id,
        type: 'DELETE',
        data: '',
        success: function() {
          item.remove();
          $('article[data-entry-id=' + entry_id + '] div.article').removeClass('highlighted');
          $('article[data-entry-id=' + entry_id + '] div.article').append('<a class="add button grey mini">highlight</a>');
        }
      });
    }
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
          $('#' + entry_id).addClass('highlighted');
        }
      });
    }
  });
});
