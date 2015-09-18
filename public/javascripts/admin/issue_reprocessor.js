$(document).ready(function(){

  function reloadPage(){
    location.reload(true);
  }

  if ($('.reprocess-issue').length){
    var reprocess_status = $('.reprocess-issue').data().status;
    if (reprocess_status === "downloading_mods" || reprocess_status === "in_progress"){
      setTimeout(reloadPage, 3000);
    }
  }

});
