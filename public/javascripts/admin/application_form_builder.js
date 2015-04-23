function add_date_picker(){
  $(".formtastic .calendar input").datepicker({
    yearRange: '-10:+4',
    dateFormat: 'mm/dd/yy',
    showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
  });
}

$(function() {
  $('.formtastic .autocomplete').each(function(){
    var parent_li = $(this);
    var name_field = $(parent_li.find('input[type=text]').first());
    var hidden_field = $(parent_li.find('input[type=hidden]').first());

    $.ajax({
      url: name_field.attr('data-source-url'),
      dataType: 'json',
      success: function(json_data){
        var data = $.makeArray($(json_data).map(function(i,obj) { return {id : obj.id, value : obj.name }; }));
        name_field.autocomplete({
          source: data,
          minLength: 0,
          select: function(event, ui) {
            name_field.val('');
            parent_li.find("ul.selected").append(
              $('<li>')
                .append(ui.item.value)
                .append(
                  $('<span class="remove">X</span>')
                )
                .append(
                  $('<input type="hidden">')
                    .attr('name',  hidden_field.attr('name'))
                    .attr('value', ui.item.id)
                )
              //'<li>' + ui.item.value + '<input type="hidden" name="' + hidden_field.attr('name') + '" value="' + ui.item.id + '" /></li>'
            );
            return false;
          }
        })
      }
    });

    parent_li.find(".selected li").live("click", function() {
      $(this).remove();
    });
  });

  // CALENDAR SUPPORT
  add_date_picker();
});
