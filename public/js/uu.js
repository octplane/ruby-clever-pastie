var hljs_languages;

function changeToLink(lang) {
  return '<a href="#'+lang+'" onclick="changeTo(\''+lang +'\');">'+lang+'</a>';
}


$(document).ready(function() {
  hljs_languages = Object.keys(hljs.LANGUAGES);
  var elt = $("#code")[0];
  hljs.highlightBlock(elt);
  var detected = $(elt).attr('class');
  $('#hljs_detected').text(detected);
  
  $('.change_to').replaceWith(function() {
    var lang = $.trim($(this).text());
    return changeToLink(lang);
  });

  $('#placeholder').replaceWith(function() {
    var o ='';
    for(i=0; i < hljs_languages.length; i++) {
      if(hljs_languages[i] == detected)
      {
        continue;
      }
      o = o + changeToLink(hljs_languages[i]) +" ";
    }
    return o
  });

});
function changeTo(lang) {
  $('#code').replaceWith(function() {
    return "<code id='code' class='"+lang+"'>"+$('#spare').text()+"</code>";
  });
  hljs.highlightBlock($('#code')[0]);
}

