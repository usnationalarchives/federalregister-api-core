//Will make inline labels and hint text
//
//Prefers hint text, any element inside the LI with class 'inline-hints'
//Will use label if no inline-hint is found
//Can select inputs with hints with selector $("input:hints")

// could just make label have the .inline-hints class too, get rid of the inline item function
// the label has a special css class that controls where it is,
// where as the inline-hint css is overridden by JS. 

//add in a force label, force hint
(function($) {

 $.fn.inlineFormElements = function(settings) {
   
   //not sure what kind of settings we need
   //color, class, what else?
    var config = {'foo': 'bar'};

    if (settings) $.extend(config, settings);
    
    this.each(function() {

      var inlineItem = $(this).getInlineItem();
      
      var input = $(this);

      //prevent the label from being selected
      $(inlineItem).bind("mousedown", function(e) {
        e.preventDefault(); 
        $(input).trigger("focus"); 
      });
      
      //if the input field is empty show the hint
      !$(this).val() ? $(inlineItem).show() : $(inlineItem).hide();
      
      //when you focus on the input element, if is empty 1) stop any current animations 2) fade out  
      $(this).bind("focus", function(){
        if (!this.value) $(inlineItem).stop(true, true).fadeOut("fast");
      });
  
      //when you lose focus of the input element, if it is empty 1) stop current animation 2) fade in
      $(this).bind("blur", function(){
        if (!this.value) $(inlineItem).stop(true, true).fadeIn("fast");
      });
      
      return this;
    });
 }
  
 //returns the element we are going to use as our text, prefers inline hints over labels
 $.fn.getInlineItem = function() {
   
   var hint = $(this).parents("li").find('.inline-hints');
   
   //would like to just add a class but not sure how best to do that yet since so much has to change
   $(hint).css("position","absolute")
          .css("color", "#aeaeae")
          .css("left", 5)
          .css("top",13)
          .parent()
          .css("position","relative");
          
   var label = $("label[for='" + $(this).attr("id")+ "']");
   
   return (hint.length > 0) ? hint : label;
 }
})(jQuery);

jQuery.extend(
 jQuery.expr[ ":" ], {
   hints: function(a){
     return $(a).parents("li").find('.inline-hints').size();
   }
 }
);

  