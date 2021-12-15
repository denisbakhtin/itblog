document.addEventListener("DOMContentLoaded",function(){
  if (document.querySelector("#ck-content")) {
    ClassicEditor.create(document.querySelector("#ck-content"),{
      language:"ru",
      ckfinder:{uploadUrl:"/admin/upload"}
    }).catch(function(e){console.error(e)});
  }

  if (document.querySelector("select#tags")) {
    $("select#tags").select2({tags:!0,tokenSeparators:[","]});
  }
}); 
