// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){ 
  $('.composite_sparkline').each( function() {
    span = $(this)
    values = span.html();
  });

  $('.composite_sparkline').sparkline(values[$(this)], {type: 'bar', barSpacing: 0, barWidth: 3, barColor: '#ddd'} );
  $('.composite_sparkline').sparkline(values, {type: 'line', lineColor: 'black', fillColor:false, composite:true} );
});