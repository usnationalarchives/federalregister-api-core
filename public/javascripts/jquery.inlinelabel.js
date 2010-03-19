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

 $.fn.inlinelabel = function(options) {
		var opt = $.extend({
		}, options);
					
    return $(this).each(function() {
      
      var input = $(this);
      
  		var getInlineItem = function() {
        $(input).after("<p class='inline-hint'>" + $(input).attr("title") + "</p>");
        var hint = $(input).next(".inline-hint");

        $(input).parent().css("position","relative");

        var input_pos        = $(input).position();

        //get the hint set up
        var hint_line_height = $(input).outerHeight() - parseCSS($(input).css("borderTopWidth"));
        var hint_css_left    = parseCSS(input_pos.left) + parseCSS($(input).css("marginLeft")) + parseCSS($(input).css("borderLeftWidth")) + 5;
        var hint_css_top     = parseCSS(input_pos.top) + parseCSS($(input).css("marginTop")) + parseCSS($(input).css("borderTopWidth"));
                
        //would like to just add a class but not sure how best to do that yet since so much has to change
        $(hint).css("position","absolute")
               .css("color", "#aeaeae")
               .css("margin", "0")
               .css("fontSize", "12px")
               .css("lineHeight", hint_line_height + "px")
               .css("left", hint_css_left)
               .css("top", hint_css_top);


        return hint;		  
  		};
  		
  		var parseCSS = function(property){
  		  //all this crud is necessary for IE8 to not blow up
        typeof(property) == 'string' ? property.replace('/D+','') : '';
        var propInt = parseInt(property, 10);
        isNaN(propInt) ? propInt = 0 : propInt;
  		  return propInt;
  		};
  		
      var inlineItem = getInlineItem();
   
      //prevent the label from being selected
      $(inlineItem).bind("mousedown", function(e) {
        e.preventDefault(); //this is preventing the blur event from happening when you click from one inline label to another
        $(input).trigger("focus"); 
        $("input.inlineHint").not(input).trigger("blur");
      });
      
      //if the input field is empty show the hint
      !$(input).val() ? $(inlineItem).show() : $(inlineItem).hide();
      
      //when you focus on the input element, if is empty 1) stop any current animations 2) fade out  
      $(input).bind("focus", function(){
        if (!$(input).val()) $(inlineItem).stop(true, true).fadeOut("fast");
      });
      
      //when you lose focus of the input element, if it is empty 1) stop current animation 2) fade in
      $(input).bind("blur", function(e){
        if (!$(input).val()) $(inlineItem).stop(true, true).fadeIn("fast");
      });
    });
  }
 
})(jQuery);

jQuery.extend(
 jQuery.expr[ ":" ], {
   hints: function(a){
     return $(a).parents("li").find('.inline-hints').size();
   }
 }
);

  