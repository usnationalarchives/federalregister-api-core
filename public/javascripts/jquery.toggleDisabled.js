/*
 * jQuery Toggle Disabled Plug-in
 *
 * Copyright (c) 2009 Dave Augustine, WestEd
 *
 * Usage: $("input").toggleDisabled();
 *
 * NOTES: TURN ME INTO A SIMPLE DISABLE/ENABLE FUNCTION
 */

(function($) {
	$.fn.toggleDisabled = function() {
		$(this).each(function()  {
			
			if( $(this).attr("disabled") == true) {
				$(this).enable;
				$(this).attr("disabled",false).removeAttr("disabled");
			}
			else {
				$(this).disable;
                $(this).attr("disabled",true);
            }
		  return $(this);
		});
	}	
	
	$.fn.enable = function() {
	  $(this).attr("disabled",false).removeAttr("disabled");
	}
	
	$.fn.disable = function() {
	  $(this).attr("disabled",true);
	}
})(jQuery);