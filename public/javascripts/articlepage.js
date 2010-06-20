$(document).ready(function() {
  //   if( $("#entries.show").size() > 0 ){
  //     $("ul.table_of_graphics").before('<div id="gallery"><div id="controls"></div><div class="slideshow-container"><div id="loading"></div><div id="slideshow"></div><div id="caption"></div></div></div>');
  //     $("ul.table_of_graphics").wrap("<div id='thumbs'></div>");
  //    $('div.navigation').css({'width' : '200px', 'float' : 'left'});
  //      var gallery = $('#thumbs').galleriffic({  
  //        imageContainerSel:      '#slideshow',
  //       controlsContainerSel:   '#controls'
  //      });
  // }
  //   
  $('div.article[data-internal-id]').each(function(){
    var id = $(this).attr('data-internal-id');
    $.ajax({
      url: '/articles/views',
      type: 'POST',
      data: {'id': id}
    });
  });
  
  var citation_info = {
    cache: {},
    setup: function( index ){
      var id = "citation_info_" + index;
      var index_el = $("#" + index);
      var box = '<div id="' + id + '" class="pull_out citation_box"><a class="sticky" href="#">Keep this open</a><dl><dt class="cite_volume">Volume</dt><dd class="cite_volume">' + $(".metadata_list .volume").text() + '</dd><dt class="cite_page">Page</dt><dd class="cite_page">' + $(".metadata_list .page").text() + '</dd><dt class="cite_date">Date</dt><dd class="cite_date"></dd></dl><ul><li class="bookmark"><a href="#">Bookmark this paragraph</a></li><li class="twitter"><a href="#">Share this on Twitter</a></li><li class="facebook"><a href="#">Share this on Facebook</a></li><li class="digg"><a href="#">Share this on digg</a></li></ul></div>'
      $("#content_area").append(box);
      var id_el = $("#" + id); 
      id_el.css({"top": index_el.position().top, "right": -id_el.width() }).data("id", index).data("sticky", false);
      this.cache[ index ] = id_el;
      return id;
    },
    show: function( id ){
      if ( this.cache[id] != null )
        this.cache[id].show();
      else {
        this.setup( id );
        this.cache[id].show();
      }  
    },
    hide: function( id ){
      if(!this.cache[id].data("sticky"))
        this.cache[id].fadeOut();
    },
    sticky: function( id ){
      var is_sticky = this.cache[id].data("sticky");
      this.cache[id].data("sticky", !is_sticky);
    }
  };

  $(".body_column table[id], .body_column p[id], .body_column img[id], .body_column li[id]").css("position","relative").append("<a href='#' class='trigger_citation_box'></a>");
  
  //TODO delegate events by binding once to the content area and inspecting the target
  // $(".body_column table[id], .body_column p[id], .body_column img[id], .body_column li[id]").bind('mouseenter', function(event) {
  //     $(event.target).trigger("show_citation");
  // });
  
  // $(".body_column table[id], .body_column p[id], .body_column img[id], .body_column li[id]").bind('mouseleave', function(event) {
  //     setTimeout(function() {
  //       $(event.target).trigger("hide_citation");
  //     }, 5000);
  // });  
  
  $(".trigger_citation_box").bind('click', function(event) {
    event.preventDefault();
    $(this).parent().trigger("show_citation");
  });
  
  $(".sticky").live('click', function(event) {
    event.preventDefault();
    citation_info.sticky( $(this).parent().data("id") );
  });
  
  $(".body_column table[id], .body_column p[id], .body_column img[id], .body_column li[id]").bind('show_citation', function(event) {
    citation_info.show( $(this).attr("id") );    
  });
  
  $(".body_column table[id], .body_column p[id], .body_column img[id], .body_column li[id]").bind('hide_citation', function(event) {
    citation_info.hide( $(this).attr("id") );    
  });

});


