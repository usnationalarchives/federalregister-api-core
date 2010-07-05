$(document).ready(function(){
  $('a.load_facet').live('click', function() {
    var anchor = $(this);
    $(this).after('<img src="/images/ui/ui-anim_basic_16x16.gif" />');
    var facet_name = anchor.attr('data-facet-name');
    var url = $(location).attr('href').replace('/search?', '/search/facets/' + facet_name + '?all=1&');
    $.ajax({
      url : url,
      success : function(data){
        anchor.closest('ul').html(data);
      }
    });
    
    return false;
  });
  
  $('body').append(['<div id="modal">',
  '  <a href="#" class="jqmClose">Close</a>',
  '  <p>Loading...</p>',
  '</div>'].join("\n")
  );
  $('#modal').jqm({ajax:'@href', trigger:'a.add_to_calendar'});
});
