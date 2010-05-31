$(document).ready(function(){
  $('a.load_facet').live('click', function() {
    var anchor = $(this);
    $(this).after('<img src="/images/ui/ui-anim_basic_16x16.gif" />');
    var facet_name = anchor.attr('data-facet-name');
    var url = $(location).attr('href').replace('/search?', '/search/facet?facet=' + facet_name + '&');
    $.ajax({
      url : url,
      success : function(data){
        anchor.closest('ul').html(data);
      }
    });
    
    return false;
  });
});
