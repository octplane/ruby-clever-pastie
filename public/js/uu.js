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
  return '<a class="clickable" onclick="changeTo(\''+lang +'\');">'+lang+'</a>';
}
function styleToLink(style) {
  return '<a class="clickable" onclick="loadStyle(\''+style +'\');">'+style+'</a>';
}


var hljs_styles = ['arta.dark', 'ascetic', 'brown_paper', 'dark.dark', 'default', 'far',
  'github', 'googlecode', 'idea', 'ir_black.dark', 'magula', 'monokai.dark', 'pojoaque.dark',
  'school_book','solarized_dark.dark', 'solarized_light', 'sunburst.dark', 'vs',
  'xcode', 'zenburn.dark' ];

$(document).ready(function() {
  p = window.location.hash.substr(1).split("&");
  parms = {};
  for(i=0; i < p.length; i++) {
    kv = p[i].split("=")
    parms[kv[0]] = kv[1];
  }
  var elt = $("#code")[0];
  if(elt) {
    hljs.highlightBlock(elt);
    var detected = $(elt).attr('class');
    cur_lang = detected;
    $('#hljs_lang').text(detected);
  }
  
  if(parms['lang']) {
    changeTo(parms['lang']);
  }
  if(parms['style']) {
    loadStyle(parms['style']);
  } else {
    silentLoadStyle('solarized_light');
  }

  hljs_languages = Object.keys(hljs.LANGUAGES);
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
  silentLoadStyle(style);
  updateHash();
}
function silentLoadStyle(style) {

  var taint = "";
  var syntax_style;

  if(style.indexOf(".") > 0) {
    var sts = style.split(".")
    syntax_style = sts[0];
    taint = sts[1];
  } else {
    syntax_style = style;
  }

  loadCssAtIdentifier("/hi/styles/" + syntax_style, 'hiStyle');
  if(taint != "") {
    loadCssAtIdentifier("/css/" + taint, 'taint');
  } else {
	$("#taint").remove();
  }
  cur_style = style;
}

function loadCssAtIdentifier(cssName, identifier)
{
  var link = $("<link>");

  link.attr({ id: identifier,
          type: 'text/css',
          rel: 'stylesheet',
          href: cssName +'.css'
  });
  $("#" + identifier).remove();
  $("head").append( link ); 
}

function changeTo(lang) {
  $('#code').replaceWith(function() {
    return "<code id='code' class='"+lang+"'>"+$('#spare').text()+"</code>";
  });
  hljs.highlightBlock($('#code')[0]);
  $('#hljs_lang').text(lang);

  cur_lang = lang;
  updateHash();
}

