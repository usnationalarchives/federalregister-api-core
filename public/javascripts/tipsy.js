$(document).ready(function(){
  
  /* ALL PAGES */
  $('.subscription.tipsy').tipsy({gravity: 'se', offset: 3, delayIn: 100, fade: true,}); // nw | n | ne | w | e | sw | s | se
  

  /* CANNED SEARCH PAGE */
  $('.doc_notice.tipsy').tipsy( {gravity: 'e', fallback: "Notice",                delayIn: 100, fade: true, offset: -4});
  $('.doc_rule.tipsy').tipsy(   {gravity: 'e', fallback: "Final Rule",            delayIn: 100, fade: true, offset: -4});
  $('.doc_prorule.tipsy').tipsy({gravity: 'e', fallback: "Proposed Rule",         delayIn: 100, fade: true, offset: -4});
  $('.doc_presdoc.tipsy').tipsy({gravity: 'e', fallback: "Presidential Document", delayIn: 100, fade: true, offset: -4});
});

