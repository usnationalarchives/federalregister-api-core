$(document).ready(function(){
  
  /* ALL PAGES */
  $('.subscription.tipsy').tipsy({gravity: 'se', offset: 3, delayIn: 100, fade: true});
  

  /* CANNED SEARCH PAGE */
  $('.doc_notice.tipsy').tipsy( {gravity: 'e', fallback: "Notice",                delayIn: 100, fade: true, offset: -4});
  $('.doc_rule.tipsy').tipsy(   {gravity: 'e', fallback: "Final Rule",            delayIn: 100, fade: true, offset: -4});
  $('.doc_prorule.tipsy').tipsy({gravity: 'e', fallback: "Proposed Rule",         delayIn: 100, fade: true, offset: -4});
  $('.doc_presdocu.tipsy').tipsy({gravity: 'e', fallback: "Presidential Document", delayIn: 100, fade: true, offset: -4});
  $('.doc_unknown.tipsy').tipsy({gravity: 'e', fallback: "Document of Unknown Type", delayIn: 100, fade: true, offset: -4});
  $('.doc_correct.tipsy').tipsy({gravity: 'e', fallback: "Correction", delayIn: 100, fade: true, offset: -4});

  $('.tip_left').tipsy({gravity:'east'});
  $('.tip_over').tipsy({gravity:'south'});
  $('.tip_right').tipsy({gravity:'west'});
  $('.tip_under').tipsy({gravity:'north'});
});

