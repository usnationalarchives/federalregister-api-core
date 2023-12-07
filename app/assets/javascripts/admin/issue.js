$(document).ready(function(){
  $('input[type=checkbox]').live('click', function(){
    // $(this)
    var form = $($(this).closest('form'));
    form.find('img').remove();
    form.find('a').prepend('<img src="/images/ui/ui-anim_basic_16x16.gif">')
    $.ajax({
      url: form.attr('action'),
      data: form.serialize(),
      type: 'PUT',
      success: function(){
        form.find('img').remove();
      }
    })
  });
});
