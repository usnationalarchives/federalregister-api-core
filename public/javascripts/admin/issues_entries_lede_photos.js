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

/* hiding dom elements that are using ContentFlow (like photo flow) 
   before ContentFlow initializes breaks the auto resizing of images
   so these methods provide a hide that uses CSS positioning instead
*/
function css_hide(object) {
  $(object).css('position', 'absolute');
  $(object).css('left', '-9999px');
}

function css_show(object) {
  $(object).css('position', 'relative');
  $(object).css('left', '0px');
}

function generate_photo_toc() {
  $('#lede_photo_candidate_topics').remove();
  
  var cycle_class = 'even';
  
  var photos = $('#lede_photo_flow .ContentFlow').map(function() {
    var id = $(this).attr('id').replace(/_flow$/, '');
    var name = $(this).find('.caption').first().html();
    
    if (cycle_class == 'odd'){
      cycle_class = 'even';
    }
    else {
      cycle_class = 'odd';
    }
    
    return '<li class="topic_link ' + cycle_class + '" id="' + id + '">' + name + '</li>';
  }).get();
  
  $('#crop-box').before('<ul id="lede_photo_candidate_topics">' + photos.join('') + '</ul>')
}
$(document).ready(function(){
  // get photo flow off the screen initially so tabs function properly
  css_hide( $('#lede_photo_flow') );
  
  $("#issue_entry_edit ul li a#content").bind('click', function(e) {
    e.preventDefault();
    if( !$(this).hasClass('active') ) {
      // change the styles on our buttons so they look pressed
      $("#issue_entry_edit ul li a#photo").removeClass('active');
      $(this).addClass('active');
      
      // hide photos and show edit fields
      $('#photo_content').hide();
      $('#entry_content').show();
    }
  });
  
  $("#issue_entry_edit ul li a#photo").bind('click', function(e) {
    e.preventDefault();
    if( !$(this).hasClass('active') ) {
      
      // bring photo flow back into position
      css_show( $('#lede_photo_flow') );
      
      // change the styles on our buttons so they look pressed
      $("#issue_entry_edit ul li a#content").removeClass('active');
      $(this).addClass('active');
      
      // hide edit fields and show photos
      $('#entry_content').hide();
      $('#photo_content').show();
      generate_photo_toc();
    }
  });
  
  // hide each topics photo flow initially
  $('.topic_photo_flow').each(function() {
    css_hide(this);
  });
  
  // show first topic
  css_show( $('.topic_photo_flow:first') );
  
  $(".topic_link").live('click', function(e){
    e.preventDefault();
    var topic_flow_id = '#' + $(this).attr('id') + '_flow'
    $('.topic_photo_flow').each(function() {
      css_hide(this);
    });
    css_show($(topic_flow_id));
  });
  
  $("#custom_tag").change(function() {
    var tag = $(this).val()
    $(this).val('');
    
    $.ajax({
      url: "/admin/photo_candidates/" + tag,
      success: function(data, textStatus, XMLHttpRequest){
        $('#lede_photo_flow').prepend(data);
        
        generate_photo_toc();
        
        var new_cf = $('#lede_photo_flow .ContentFlow').first();
        var ajax_cf = new ContentFlow(new_cf.attr('id'), {onclickActiveItem: prepare_to_crop_image});
        ajax_cf.init();
        
        $('.topic_link').first().click();
        // new_cf.find('img').each(function(index, value){
        //   ajax_cf.addItem($(value), 'last');
        // });
      }
    });
  });
});
