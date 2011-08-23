$(document).ready(function(){
  
  /* ALL PAGES */
  $('.subscription.tipsy').tipsy({gravity: 'se', offset: 3, fade: true,}); // nw | n | ne | w | e | sw | s | se
  

  /* CANNED SEARCH PAGE */
  $('.doc_notice.tipsy').tipsy({gravity: 'e', fallback: "Notice", delayIn: 200, fade: true, offset: -7, trigger: 'manual'}).bind('click', function(){ $(this).tipsy("show");});
  $('.rule.tipsy').tipsy({gravity: 'e', fallback: "Final Rule", delayIn: 200, fade: true, offset: -7});
  $('.prorule.tipsy').tipsy({gravity: 'e', fallback: "Proposed Rule", delayIn: 200, fade: true, offset: -7});
});

