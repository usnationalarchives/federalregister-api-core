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

function prepare_to_crop_image(item) {
  var img = $(item.content).first();
  var src = img.attr('data-photo-large-url');
  $('#entry_lede_photo_attributes_url').val(src);
  $('#entry_lede_photo_attributes_flickr_photo_id').val(img.attr('data-photo-id'));
//  $('#preview').val(src);
  $('#crop-box').html('<img src="' + src + '" />');
  $('#preview').html('<img src="' + src + '" />');
  
  $('.modal').jqmShow();
  $('fieldset#photo_preview').remove();
  
  $('#crop-box img').Jcrop({
    onChange: showPreview,
    onSelect: function(c){
      showPreview(c);
      $('#entry_lede_photo_attributes_crop_x').val(c.x);
      $('#entry_lede_photo_attributes_crop_y').val(c.y);
      $('#entry_lede_photo_attributes_crop_width').val(c.w);
      $('#entry_lede_photo_attributes_crop_height').val(c.h);
    },
    aspectRatio: 16/7,
    bgColor: 'yellow',
    bgOpacity: 0.8,
    allowMove: true
  });
}

$.fn.imagesLoaded = function(callback){
  var elems = this.find('img').andSelf().filter('img'),
      len   = elems.length;
  elems.bind('load',function(){
      if (--len <= 0){ callback.call(elems,this); }
  }).each(function(){
     // cached images don't fire load sometimes, so we reset src.
     if (this.complete || this.complete === undefined){
        var src = this.src;
        // webkit hack from http://groups.google.com/group/jquery-dev/browse_thread/thread/eee6ab7b2da50e1f
        // data uri bypasses webkit log warning (thx doug jones)
        this.src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==";
        this.src = src;
     }  
  }); 

  return this;
};

$(document).ready(function(){
  $('.modal').jqm({modal: true});
  $('.jqmOverlay').live('click', function(){
    $('.modal').jqmHide();
 //   $('#preview').clone().prependTo('form.formtastic.entry');
    $('form.formtastic.entry div#preview').removeAttr('id').attr('id', 'entry_photo_preview').wrap('<fieldset id="photo_preview" class="inputs"><ol><li>');
    $('fieldset#photo_preview ol li div#entry_photo_preview').before('<label for="entry_photo_preview">Photo</label>');
  });
  
  $("#custom_tag").change(function() {
    var tag = $(this).val();
    $(this).val('');
    
    $('.topic_photo_flow:first').hide();
    $('#blank_flow').show();
    
    $.ajax({
      url: "/admin/photo_candidates/" + tag,
      success: function(data, textStatus, XMLHttpRequest){
        $('#blank_flow').hide();
        $('#lede_photo_flow').prepend(data);
        $('#lede_photo_flow').imagesLoaded(function() { 
          var new_cf = $('#lede_photo_flow .ContentFlow').first();
          var ajax_cf = new ContentFlow(new_cf.attr('id'), {
            circularFlow:false,
            startItem:'start',
            onclickActiveItem: prepare_to_crop_image,
            reflectionHeight: 0.25
          });
          ajax_cf.init();
        });
      }
    });
  });
});
