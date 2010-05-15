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

function prepare_to_crop_image(item) {
  var img = $(item.content).first();
  var src = img.attr('src').replace(/_m\./, '.');
  $('#entry_lede_photo_attributes_url').val(src);
  $('#entry_lede_photo_attributes_flickr_owner_id').val(img.attr('data-owner-id'));
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
}

$(document).ready(function(){
  $("#custom_tag").change(function() {
    var tag = $(this).val()
    
    $.ajax({
      url: "/admin/photo_candidates/" + tag,
      success: function(data, textStatus, XMLHttpRequest){
        $('#lede_photo_flow').prepend(data);
        var new_cf = $('#lede_photo_flow .ContentFlow').first();
        var ajax_cf = new ContentFlow(new_cf.attr('id'), false);
        ajax_cf.init();
        
        new_cf.find('img').each(function(index, value){
          ajax_cf.addItem($(value), 'last');
        });
      }
    });
  });
});
