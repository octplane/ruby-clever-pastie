var hljs_languages;

var cur_lang;
var cur_style;

function updateHash()
{
  var hashS ="";
  if(cur_lang)
  {
    hashS = hashS + "lang=" + cur_lang;
  }
 if(cur_style)
  {
    hashS = hashS + "&style=" + cur_style;
  }
  document.location.hash = hashS;
}

function changeToLink(lang) {
  return '<a onclick="changeTo(\''+lang +'\');">'+lang+'</a>';
}
function styleToLink(style) {
  return '<a onclick="loadStyle(\''+style +'\');">'+style+'</a>';
}


var hljs_styles = ['arta', 'ascetic', 'brown_paper' ];

$(document).ready(function() {
  console.log(window.location);

  hljs_languages = Object.keys(hljs.LANGUAGES);
  var elt = $("#code")[0];
  if(elt) {
    hljs.highlightBlock(elt);
    var detected = $(elt).attr('class');
    cur_lang = detected;
    $('#hljs_detected').text(detected);
  }
  
  $('.change_to').replaceWith(function() {
    var lang = $.trim($(this).text());
    return changeToLink(lang);
  });

  // $('.style_to').replaceWith(function() {
  //   var lang = $.trim($(this).text());
  //   return loadStyle(lang);
  // });

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


  $('#style-placeholder').replaceWith(function() {
    var o ='';
    for(i=0; i < hljs_styles.length; i++) {
      o = o + styleToLink(hljs_styles[i]) +" ";
    }
    return o
  });

  $('#never_expire').change( function(o) {
    var state = $(this).is(':checked');
    if(state)
    {
      $('#expiry_delay').attr('disabled', 'disabled');
    } else {
      $('#expiry_delay').removeAttr('disabled');
    }
  });

});

function loadStyle(style) {
  var link = $("<link>");

  link.attr({
          type: 'text/css',
          rel: 'stylesheet',
          href: '/hi/styles/'+style+'.css'
  });
  $("head").append( link ); 
  cur_style = style;
  updateHash();
}

function changeTo(lang) {
  $('#code').replaceWith(function() {
    return "<code id='code' class='"+lang+"'>"+$('#spare').text()+"</code>";
  });
  hljs.highlightBlock($('#code')[0]);
  cur_lang = lang;
  updateHash();
}

