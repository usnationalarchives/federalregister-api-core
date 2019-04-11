function showPreview(coords) {
  var rx = 160 / coords.w;
  var ry = 70 / coords.h;

  $('#preview img').css({
    width: Math.round(rx * 500) + 'px',
    height: Math.round(ry * 370) + 'px',
    marginLeft: '-' + Math.round(rx * coords.x) + 'px',
    marginTop: '-' + Math.round(ry * coords.y) + 'px'
  });
}



$(document).ready(function(){
  $('.modal').jqm({modal: true});
  $('.jqmOverlay').live('click', function(){
    $('.modal').jqmHide();
 //   $('#preview').clone().prependTo('form.formtastic.entry');
    $('form.formtastic.entry div#preview').removeAttr('id').attr('id', 'entry_photo_preview').wrap('<fieldset id="photo_preview" class="inputs"><ol><li>');
    $('fieldset#photo_preview ol li div#entry_photo_preview').before('<label for="entry_photo_preview">Photo</label>');
  });
});
