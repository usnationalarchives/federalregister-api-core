$(document).ready(function(){
  function showPreview(coords) {
    var rx = 100 / coords.w;
    var ry = 100 / coords.h;

    $('#preview img').css({
      width: Math.round(rx * 500) + 'px',
      height: Math.round(ry * 370) + 'px',
      marginLeft: '-' + Math.round(rx * coords.x) + 'px',
      marginTop: '-' + Math.round(ry * coords.y) + 'px'
    });
  }
  
  $('#candidates li img').live('click', function() {
    var src = $(this).attr('src').replace(/_m\./, '.');
    $('#entry_lede_photo_attributes_url').val(src);
    $('#entry_lede_photo_attributes_flickr_owner_id').val($(this).attr('data-owner-id'));
    $('#preview').val(src);
    $('#crop-box').html('<img src="' + src + '" />')
    $('#preview').html('<img src="' + src + '" />');
    
    $('#crop-box img').Jcrop({
      onChange: showPreview,
      onSelect: function(c){
        showPreview(c);
        $('#entry_lede_photo_attributes_crop_x').val(c.x);
        $('#entry_lede_photo_attributes_crop_y').val(c.y);
        $('#entry_lede_photo_attributes_crop_width').val(c.w);
        $('#entry_lede_photo_attributes_crop_height').val(c.h);
      },
      aspectRatio: 1,
      bgColor: 'yellow',
      bgOpacity: .8,
    });
  });
});
