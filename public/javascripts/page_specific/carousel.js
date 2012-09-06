/*!
 *  FR2 iScroll 4 Setup
 */
function load_iScroll() {
  var previousPage = 0;
  var numberOfPages = $('#main_carousel_wrapper #carousel_scroller').find('li').size();
  var myScroll = new iScroll('main_carousel_wrapper', {
    snap: 'li',
    momentum: false,
    hScrollbar: false,
    vScroll: false,
    onScrollEnd: function () {
      var active_li = $("#indicator li.active");
      if (this.currPageX > previousPage && this.currPageX < numberOfPages) {
        active_li.next('li').addClass('active');
        previousPage = this.currPageX;
        active_li.removeClass("active");
      } else if (this.currPageX < previousPage && this.currPageX >= 0) {
        active_li.prev('li').addClass('active');
        previousPage = this.currPageX;
        active_li.removeClass("active");
      }
    }
  });

  $('#carousel-nav #prev').live('click', function(event) {
    event.preventDefault();
    myScroll.scrollToPage('prev', 0);
  });

  $('#carousel-nav #next').live('click', function(event) {
    event.preventDefault();
    myScroll.scrollToPage('next', 0);
  });
  return myScroll;
}

/*!
 *  FR2 Carousel
 */
$(document).ready(function(){
  /* we have two carousels on the page but only want one to be iScroll'd */
  $('#main #carousel_wrapper').attr('id', 'main_carousel_wrapper');
  var myScroll = load_iScroll();

  var carousel_rounded_corner_size = 18;
  var carousel_size = 350;
  var navigation_height = 18;
  
  /* text_wrappers are also in nav and we don't want to modify those */
  $("#main .text_wrapper").each(function() {
    var text_wrapper = $(this);
    var box_y_position = carousel_size - (carousel_rounded_corner_size * 2) - navigation_height - text_wrapper.height();      
    text_wrapper.css('top', box_y_position).css('width', $(this).width());
    
    var text_bg = text_wrapper.siblings('div.bg').first();
    text_bg.css('top', box_y_position).css('width', $(this).width()).css('height', text_wrapper.height());
  });
  
  $(".attribution").not('.bg').each(function() {
    var attribution_bg = $(this).siblings('div.bg.attribution').first();
    attribution_bg.css('width', $(this).width()).css('height', '0px');
  });
 
});
