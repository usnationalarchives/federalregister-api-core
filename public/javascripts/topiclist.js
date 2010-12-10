$(document).ready(function () {
    //clear the live search so it's not confusing
    $("#topics li.livesearch input").val("").trigger("blur");
  
    $("#topics li.livesearch input").bind("keyup",
    function (e) {
        $("#topic_list > li").hide().find("a:regex('\\b" + $(this).attr("value") + "')").parent().show();
        $("#topic_list").trigger('filter', $(this).val());
    }).bind("focus",
    function (e) {
        $("#topics ul.filter li").removeClass("on");
        $(this).parent().addClass("on");
    });


    $("#topics .filters .alpha li a").bind("click",
    function (e) {
        e.preventDefault();

        $("#topics .filters .alpha li").removeClass("on");
        $(this).parent().addClass("on");

        if ($(this).parent().hasClass("all")) {
          $("#topic_list > li").show();
        }
        else {
          $("#topic_list > li").hide().find("a:regex('^[" + $(this).html() + "]')").parent().show();
        }
        $("#topic_list").trigger('filter', $(this).text());
    });


    $("#topic_list").bind('filter',
    function (event, item) {
        $("#topic_count").html($("#topic_list > li:visible").size());
        $("h1.title span").text('Topics - ' + item);
    });


    $(".topic_list_container .actions a").bind('click',
    function (event) {
        event.preventDefault();

        switch ($(this).attr("href")) {
        case '#asc':
            $("#topic_list>li").tsort('a');
            break;
        case '#dec':
            $("#topic_list>li").tsort('a', {
                order: "desc"
            });
            break;
        case '#pop-asc':
            $("#topic_list>li").tsort('.individual_topic_count');
            break;
        case '#pop-dec':
            $("#topic_list>li").tsort('.individual_topic_count', {
                order: "desc"
            });
            break;
        }

        $(".topic_list_container .actions .on").removeClass("on");
        $(this).parent().addClass("on");
    });


});
