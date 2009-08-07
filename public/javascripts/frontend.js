$(document).ready(function() {
  
  /***********************************  
  * SEARCH FILTER
  **********************************/
 //hide and disable the form on entry
 $("form li:not('.simple')").toggle().find("li").children(":not(label)").disable();
 
 //when the button is clicked - change the button text, toggle the open class, and show/hide enable/disable
  $("a.options").bind("click", function(e){
    e.preventDefault();
    
    if($(this).hasClass("open"))
      $(this).html($(this).html().replace('Hide', "Show"));
    else
      $(this).html($(this).html().replace('Show', "Hide"));
      
    $(this).toggleClass("open");
    
    $("form li:not('.simple')").toggle().find("li").children(":not(label)").toggleDisabled();
  });
  
  $('.tag_cloud').each(function(){
    $('.tag_cloud ul').hide();
    var tagcloud = new TagCloud(document.getElementById('fancy_tag_cloud'),'descending',[{r:255,g:255,b:0},{r:0,g:0,b:255}],[{r:255,g:255,b:0},{r:0,g:0,b:255}], '/topics/');
    $('.tag_cloud li').each(function(){
      var li = $(this)
      var text = li.text();
      var name = text.replace(/ \(\d+\)/,'');
      var count = text.replace(/.*\(|\).*/g,'') / 7
      console.log(count);
      tagcloud.addNode(new Node(name, count));
    });
  
    tagcloud.draw();
  });
});
