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
      var box = '<div id="' + id + '" class="pull_out citation_box"><ul><li class="link"><a href="/a/'+ $(".doc_number").text() + '/#' + index +'">Link to this paragraph</a></li><li class="cite_volume"><strong>Citation</strong> ' + $(".metadata_list .volume").text() + ' FR ' + $(".metadata_list .page").text() + '</li><li class="cite_page"><strong>Page</strong> ' + $(".metadata_list .page").text() + '</li><li class="email"><a href="#">Email this</a></li><li class="twitter"><a href="#">Share this on Twitter</a></li><li class="facebook"><a href="#">Share this on Facebook</a></li><li class="digg"><a href="#">Share this on digg</a></li></ul></div>'
      $("#sidebar").append(box);
      var id_el = $("#" + id); 
      id_el.css({"top": index_el.position().top + 6, "right": 0}).data("id", index).data("sticky", false);
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


