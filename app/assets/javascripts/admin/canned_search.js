$(document).ready(function() {
  if ($("#canned_searches tbody.active_canned_searches").length > 0) {
    $("#canned_searches tbody.active_canned_searches").sortable({
      stop: function(event, ui) {
        var canned_search_id = ui.item.attr('data-canned-search-id');
        var position = ui.item.prevAll('tr').size() + 1;
        $.ajax({
          url: '/admin/canned_searches/' + canned_search_id,
          type: 'PUT',
          data: "canned_search[new_position]=" + position,
          success: function() {
            $('#canned_search_' + canned_search_id).effect('highlight', {}, 3000);
            show_separator();
          }
        })
      }
    });
    
    function show_separator() {
      $('#canned_searches tbody tr').removeClass('separator');
      $('#canned_searches tbody tr:eq(3)').addClass('separator');
    }
    show_separator();
  }
});
