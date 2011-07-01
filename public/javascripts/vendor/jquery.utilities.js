/* Agency list view sorting - see commit 1ea203ff */
jQuery.extend(  
    jQuery.expr[':'], {  
        regex: function(a, i, m, r) {  
            var r = new RegExp(m[3], 'i');  
            return r.test(jQuery(a).text());  
        }  
    }  
);  

jQuery.extend(
  jQuery.expr[':'], {
    Contains: "jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0"
});

/* Randomly choose which section to go to in the section highlight box on home page - see commit 71f0e595 */
// http://blog.mastykarz.nl/jquery-random-filter/
jQuery.jQueryRandom = 0;
jQuery.extend(
  jQuery.expr[":"], {
    random: function(a, i, m, r) {
        if (i == 0) {
            jQuery.jQueryRandom = Math.floor(Math.random() * r.length);
        };
        return i == jQuery.jQueryRandom;
    }
});

/* Modal window centering - see commit 2cs91e1e */
//http://groups.google.com/group/jquery-en/browse_thread/thread/a890828a14d86737
//modified by DMA to use outerHeight, outerWidth
jQuery.fn.centerScreen = function(loaded) {
  var obj = this;
  if(!loaded) {
    obj.css('left', $(window).width()/2-this.outerWidth()/2);
    $(window).resize(function(){ 
      obj.centerScreen(!loaded); 
    });
  } else {
    obj.stop();
    obj.animate(
      { left: $(window).width()/2-this.outerWidth()/2 }, 200, 'linear');
    }
    return obj;  
  };