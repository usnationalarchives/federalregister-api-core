$(document).ready(function() {

  $(".section_nav li a").bind('click', function(event) {
    event.preventDefault();
    $(".section_nav li").removeClass("on");
    $(this).parent().addClass("on");
    $(".news_items").scrollTo($(this).attr("href"));
  });
  
  $(".section_nav li:first-child a").trigger("click");
  
});

