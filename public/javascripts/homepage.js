$(document).ready(function () {
    if ($("#special").hasClass("home")) {
        var slideshow = new Dragdealer('slideshow', {
            vertical: true,
            steps: 6
        });

        slideshow.disable();

        $(".section_nav a").bind('click',
        function (event) {
            event.preventDefault();
            $(".section_nav li").removeClass("on");
            $(this).parent().addClass("on");
            slideshow.setStep(0, $(".section_nav li").index($(this).parent()) + 1);
        });

        var adjustedHigh = (parseFloat($(".section_nav li").size()));
        var numRand = Math.floor(Math.random() * adjustedHigh);
        var item = $(".section_nav li a").get(numRand);
        $(item).trigger("click");
    }
    
    if( $("#learn").size() > 0 ){    
      $("#learn").addClass("active");
      $("#learn").tabs();
    }
  
  if( $("#popular").size() > 0 ){
      $("#popular").addClass("active");
      $("#popular").tabs();
  }
});
