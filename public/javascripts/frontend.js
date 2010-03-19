$(document).ready(function() {
  
  $("#feedback").bind("click", function(){
    $("html, body").animate({scrollTop: 0}, 400);
    $("#tender_window").parent().addClass("modal");
    
    $(".wml-marker").each(function(){
      $(this).data("oldzindex", $(this).css("z-index")).css("z-index", 1);
    });
    
    $(".wml-large-map-control").css("z-index", 1);
    
    $("#tender_closer").one("click", function(){
      $("#tender_window").parent().removeClass("modal");
      $(".wml-large-map-control").css("z-index", 200000);      
      $(".wml-marker").each(function(){
        $(this).css("z-index", $(this).data("oldzindex"));
      });   
    });
  });
  
  //modal open and close
  $(".spawn_modal").bind("click", function(e){
    if( !($.browser.msie && $.browser.version == 6) ){
      e.preventDefault();
      pageTracker._trackPageview('/entries/widget_modal');
      var modal_id = $(this).attr("id");
      var modal_node = $("#modal_" + modal_id);
      
      $("html, body").animate({scrollTop: 0}, 400);
      
      $("#footer").after("<div class='modal'></div>");
      $(modal_node).show().centerScreen();
      $("body").css("overflow","hidden");
      $(".modal").width( $("body").width() )
                 .height( $("body").height() );
                 
      $(modal_node).find("a.cancel").add(".modal").one("click", function(e){
        e.preventDefault(); 
        $(modal_node).hide();
        $(".modal").remove();
        $("body").css("overflow","auto");
      });
    }
  });
  
  $("#feedback").bind("mouseenter", function(){
    $(this).animate({left: -5}, 200); 
  });
 
  $("#feedback").bind("mouseleave", function(){
    $(this).animate({left: -10}, 200);
  });
   
  //$(":text").labelify({ labelledClass: "labelHighlight" });
  $("input.inlineHint").inlinelabel();
  
  // This needs to be fixed to use a proper slug - may require url rewriting.
  $('.tag_cloud').each(function(){
    $('.tag_cloud ul').hide();
    var tagcloud = new TagCloud(document.getElementById('fancy_tag_cloud'),'descending',[{r:255,g:167,b:105},{r:250,g:159,b:94},{r:244,g:150,b:84},{r:239,g:142,b:73},{r:233,g:133,b:63},{r:227,g:125,b:52},{r:222,g:117,b:42},{r:216,g:108,b:31},{r:211,g:100,b:21},{r:205,g:91,b:10},{r:199,g:83,b:0}],[{r:0,g:80,b:115},{r:13,g:92,b:125},{r:26,g:105,b:136},{r:39,g:118,b:146},{r:53,g:130,b:157},{r:66,g:143,b:167},{r:79,g:156,b:178},{r:92,g:168,b:188},{r:106,g:181,b:198},{r:119,g:194,b:109},{r:132,g:206,b:219}], '/topics/');
    $('.tag_cloud li').each(function(){
      var li = $(this)
      var text = li.text();
      var name = text.replace(/ \(\d+\)/,'');
      var count = text.replace(/.*\(|\).*/g,'') / 7;
      var slug = $(li.find('a').get(0)).attr('href').replace(/.*\/topics\//,'');
      tagcloud.addNode(new Node(name, count, slug));
    });
  
    tagcloud.draw();
  });
  
  $('ul.searchform span.advanced a').bind('click', function(e){
    e.preventDefault();
    $('ul.searchform li.advanced').toggleClass('hidden');
  });
  
  $('ul.searchform li.advanced input').bind('focus', function(e){
    $('ul.searchform li.advanced input').bind('keyup', function(e){
      $('ul.searchform li input#q').val(constuct_sphinx_query());
    });
  });
  
  $('ul.searchform li.advanced input').bind('blur', function(e){
    $('ul.searchform li.advanced input').unbind('keyup');
  });
  
});

//http://groups.google.com/group/jquery-en/browse_thread/thread/a890828a14d86737
//modified by DMA to use outerHeight, outerWidth
jQuery.fn.centerScreen = function(loaded) {
  var obj = this;
  if(!loaded) {
    obj.css('left', $(window).width()/2-this.outerWidth()/2);
    $(window).resize(function(){ 
      obj.centerScreen(!loaded); 
      });} else {
        obj.stop();
        obj.animate({ 
          left: $(window).width()/2-this.outerWidth()/2}, 200, 'linear');
        $(".modal_bg").width( $("body").width() );
      }
}

function constuct_sphinx_query() {
  var query = '';
  
  exact_terms   = $('ul.searchform li.advanced input#exact').val();
  
  boolean_terms = $('ul.searchform li.advanced input.boolean[value != ""]').map(function() {
    return $(this).val();
  }).get().join(' | ');
  
  ignore_terms = '';
  if( $('ul.searchform li.advanced input#ignore').val() != '' ){
    ignore_terms = " -" + $('ul.searchform li.advanced input#ignore').val().split(" ").join(" -");
  }
  
  if( exact_terms   != '' ) { query =  '"' + exact_terms   + '" '; }
  if( boolean_terms != '' ) { query += "(" + boolean_terms + ') '; }
  query += ignore_terms
  
  return query;
}