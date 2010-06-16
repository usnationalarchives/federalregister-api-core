$(document).ready(function() {

  $(".section_nav li a").bind('click', function(event) {
    event.preventDefault();
    $(".section_nav li").removeClass("on");
    $(this).parent().addClass("on");
    $(".news_items").scrollTo($(this).attr("href"));
  });


  var adjustedHigh = (parseFloat( $(".section_nav li").size()));
  var numRand = Math.floor(Math.random()*adjustedHigh);  
  $( $(".section_nav li a").get(numRand) ).trigger("click");

    
});

