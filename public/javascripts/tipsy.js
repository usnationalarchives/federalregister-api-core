$(document).ready(function(){
  
  /* ALL PAGES */
  $('.subscription.tipsy').tipsy({gravity: 'se', offset: 3, delayIn: 100, fade: true});
  

  /* CANNED SEARCH PAGE */
  $('#canned_searches .doc_notice.tipsy').tipsy( {gravity: 'e', fallback: "Notice",                delayIn: 100, fade: true, offset: -4});
  $('#canned_searches .doc_rule.tipsy').tipsy(   {gravity: 'e', fallback: "Final Rule",            delayIn: 100, fade: true, offset: -4});
  $('#canned_searches .doc_prorule.tipsy').tipsy({gravity: 'e', fallback: "Proposed Rule",         delayIn: 100, fade: true, offset: -4});
  $('#canned_searches .doc_presdocu.tipsy').tipsy({gravity: 'e', fallback: "Presidential Document", delayIn: 100, fade: true, offset: -4});
  $('#canned_searches .doc_unknown.tipsy').tipsy({gravity: 'e', fallback: "Document of Unknown Type", delayIn: 100, fade: true, offset: -4});
  $('#canned_searches .doc_correct.tipsy').tipsy({gravity: 'e', fallback: "Correction", delayIn: 100, fade: true, offset: -4});

  /* AGENCY PAGE */
  $('#agencies .doc_presdocu.tipsy').tipsy({ gravity: 'e', delayIn: 100, fade: true, offset: 0,
                                             title: function() { return $(this).data('tooltip');},
                                             fallback: "Presidential Document"
                                           });
  $('#agencies .doc_notice.tipsy').tipsy( {gravity: 'e', fallback: "Notice",                   delayIn: 100, fade: true, offset: 0});
  $('#agencies .doc_rule.tipsy').tipsy(   {gravity: 'e', fallback: "Final Rule",               delayIn: 100, fade: true, offset: 0});
  $('#agencies .doc_prorule.tipsy').tipsy({gravity: 'e', fallback: "Proposed Rule",            delayIn: 100, fade: true, offset: 0});
  $('#agencies .doc_unknown.tipsy').tipsy({gravity: 'e', fallback: "Document of Unknown Type", delayIn: 100, fade: true, offset: 0});
  $('#agencies .doc_correct.tipsy').tipsy({gravity: 'e', fallback: "Correction",               delayIn: 100, fade: true, offset: 0});


  /* Doctype Filters */
  $('#doc-type-search-filter li').tipsy( {gravity: 'n', fade: true, offset: 2, title: function() { return $(this).data('tooltip');} });


  $('.tip_left').tipsy({gravity:'east'});
  $('.tip_over').tipsy({gravity:'south'});
  $('.tip_right').tipsy({gravity:'west'});
  $('.tip_under').tipsy({gravity:'north'});
});

