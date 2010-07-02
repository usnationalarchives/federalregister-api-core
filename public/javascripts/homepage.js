$(document).ready(function() {

  // $(".section_nav li a").bind('click', function(event) {
  //   event.preventDefault();
  //   $(".section_nav li").removeClass("on");
  //   $(this).parent().addClass("on");
  //   $(".news_items").scrollTo($(this).attr("href"));
  // });
    
  var slideshow = new Dragdealer('slideshow',
  {
  	steps: 6,
  	loose: true,
  	animationCallback: function(x,y) {
  	  
  	}  
  	});
    
  $(".section_nav a").bind('click', function(event) {
    event.preventDefault();
    $(".section_nav li").removeClass("on");
    $(this).parent().addClass("on");
    slideshow.setStep( $(".section_nav li").index( $(this).parent() )  + 1);
  });
    
  var adjustedHigh = (parseFloat( $(".section_nav li").size()));
  var numRand = Math.floor(Math.random()*adjustedHigh);  
  
  var item = $(".section_nav li a").get(numRand);
  $(item).trigger("click");

    
});

