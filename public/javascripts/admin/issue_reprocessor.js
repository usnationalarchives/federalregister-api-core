$(document).ready(function(){
  function reloadPage(){
    location.reload(true)
  };

  if ($('.reprocess-issue-page').data().status !== "pending_reprocess"){
    setTimeout(reloadPage, 3000);
  }
});
