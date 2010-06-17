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
  })
});