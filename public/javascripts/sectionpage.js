$(document).ready(function () {

    if ($("#comments-closing-opening").size() > 0) {
        $("#comments-closing-opening").addClass("active");
        $("#comments-closing-opening").tabs();
        $(".TOC a").bind('click',
        function (event) {
            $(window).scrollTop($("#comments-closing-opening").offset().top);
        });        
    }
    
    if( $("#articles_published_by_day").size() > 0 ){    
      $("#articles_published_by_day").addClass("active");
      $("#articles_published_by_day").tabs();
    }
    if( $("#popular-things").size() > 0 ){
      $("#popular-things").addClass("active");
      $("#popular-things").tabs();
    }
});
