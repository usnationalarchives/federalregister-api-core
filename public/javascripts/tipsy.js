$(document).ready(function(){
  
  /* ALL PAGES */
  $('.subscription.tipsy').tipsy({gravity: 'se', offset: 3, delayIn: 100, fade: true});
 
  /* NAVIGATION */
  $('.previewable .right_column table .past_7_days, .previewable .right_column table .recently_opened, .previewable .right_column table .closing_soon').each( function() {
    $(this).tipsy({ gravity: 's', delayIn: 100, fade: true, offset: 0,
                    title: function() { return $(this).data('tooltip');}
                  });
  });

  /* CALENDAR */
  $('table.calendar td.holiday').tipsy({ gravity: 's', delayIn: 100, fade: true, offset: 0});

  /* Doctype Filters */
  $('#doc-type-search-filter li').tipsy( {gravity: 'n', fade: true, offset: 2, title: function() { return $(this).data('tooltip');} });

  /* NAVIGATION (pluralized tooltips) */
  $('#navigation .doc_notice.tipsy').tipsy(  {gravity: 's', fallback: "Notice",                   delayIn: 100, fade: true, offset: 4});
  $('#navigation .doc_rule.tipsy').tipsy(    {gravity: 's', fallback: "Final Rule",               delayIn: 100, fade: true, offset: 4});
  $('#navigation .doc_prorule.tipsy').tipsy( {gravity: 's', fallback: "Proposed Rule",            delayIn: 100, fade: true, offset: 4});
  $('#navigation .doc_presdocu.tipsy').tipsy({gravity: 's', fallback: "Presidential Document",    delayIn: 100, fade: true, offset: 4});
  $('#navigation .doc_unknown.tipsy').tipsy( {gravity: 's', fallback: "Document of Unknown Type", delayIn: 100, fade: true, offset: 4});
  $('#navigation .doc_correct.tipsy').tipsy( {gravity: 's', fallback: "Correction",               delayIn: 100, fade: true, offset: 4});

  /* AGENCY PAGE, TOPICS, CANNED SEARCHES */
  $('.doc_presdocu.tipsy').tipsy({ gravity: 'e', delayIn: 100, fade: true, offset: 0,
                                             title: function() { return $(this).data('tooltip');},
                                             fallback: "Presidential Document"
                                           });
  $('.doc_notice.tipsy').tipsy(  {gravity: 'e', fallback: "Notice",                   delayIn: 100, fade: true, offset: 0});
  $('.doc_rule.tipsy').tipsy(    {gravity: 'e', fallback: "Final Rule",               delayIn: 100, fade: true, offset: 0});
  $('.doc_prorule.tipsy').tipsy( {gravity: 'e', fallback: "Proposed Rule",            delayIn: 100, fade: true, offset: 0});
  $('.doc_unknown.tipsy').tipsy( {gravity: 'e', fallback: "Document of Unknown Type", delayIn: 100, fade: true, offset: 0});
  $('.doc_correct.tipsy').tipsy( {gravity: 'e', fallback: "Correction",               delayIn: 100, fade: true, offset: 0});


  $('.tip_left').tipsy({gravity:'east'});
  $('.tip_over').tipsy({gravity:'south'});
  $('.tip_right').tipsy({gravity:'west'});
  $('.tip_under').tipsy({gravity:'north'});
});

