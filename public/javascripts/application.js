// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function() {
  
  if($(".daily")){
    $(".daily").easySlider({
      auto: true,
      continuous: true,
      pause: 4000,
      controlsShow: false,
      vertical: true 
  	});
  }
});
