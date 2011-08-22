/*!
 *  iScroll 4 Setup
 */
var myScroll;
 
function loaded() {
  myScroll = new iScroll('carousel_wrapper', {
    snap: 'li div',
    momentum: false,
    hScrollbar: false,
    onScrollEnd: function () {
      document.querySelector('#indicator > li.active').className = '';
      document.querySelector('#indicator > li:nth-child(' + (this.currPageX+1) + ')').className = 'active';
    }
  });
}

document.addEventListener('DOMContentLoaded', loaded, false);


/*!
 *  FR2 Carousel
 */
$(document).ready(function(){

  var carousel_rounded_corner_size = 18;
  var carousel_size = 350;
  var navigation_height = 18;
  
  $(".text_wrapper").each(function() {
    var text_wrapper = $(this);
    var box_y_position = carousel_size - (carousel_rounded_corner_size * 2) - navigation_height - text_wrapper.height();      
    text_wrapper.css('top', box_y_position).css('width', $(this).width());
    
    var text_bg = text_wrapper.siblings('div.bg').first();
    text_bg.css('top', box_y_position).css('width', $(this).width()).css('height', text_wrapper.height());
  });
  
  $(".attribution").not('.bg').each(function() {
    var attribution_bg = $(this).siblings('div.bg.attribution').first();
    attribution_bg.css('width', $(this).width());
  });

  $('#carousel-nav #prev').live('click', function(event) {
    event.preventDefault();
    myScroll.scrollToPage('prev', 0)
  });

  $('#carousel-nav #next').live('click', function(event) {
    event.preventDefault();
    myScroll.scrollToPage('next', 0)
  });

});

