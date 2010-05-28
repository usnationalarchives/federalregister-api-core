$(document).ready(function() {
  $("ul.table_of_graphics").before('<div id="gallery"><div id="controls"></div><div class="slideshow-container"><div id="loading"></div><div id="slideshow"></div><div id="caption"></div></div></div>');
  $("ul.table_of_graphics").wrap("<div id='thumbs'></div>");
	$('div.navigation').css({'width' : '200px', 'float' : 'left'});
   var gallery = $('#thumbs').galleriffic({	
     imageContainerSel:      '#slideshow',
		 controlsContainerSel:   '#controls'
		});
});
