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

function loadCommentsForm(postId) {
    var xmlhttp = new XMLHttpRequest();

    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == XMLHttpRequest.DONE) {   // XMLHttpRequest.DONE == 4
           if (xmlhttp.status == 200) {
               document.getElementById("comments-form").innerHTML = xmlhttp.responseText;
           }
           else if (xmlhttp.status == 400) {
              alert('There was an error 400');
           }
           else {
               alert('something else other than 200 was returned');
           }
        }
    };

    xmlhttp.open("GET", "/comments/form/"+postId, true);
    xmlhttp.send();
}
