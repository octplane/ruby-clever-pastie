var hljs_languages;

var cur_lang;
var cur_style;

function updateHash()
{
  var hashS ="";
  if(password)
  {
    hashS = hashS + "clef=" + password;
  }
  if(cur_lang)
  {
    hashS = hashS + "&lang=" + cur_lang;
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
function generatePassword(length) {
  var pass=Math.abs(sjcl.random.randomWords(1)[0]);
  var p = "";
  while(p.length < length) {
    p = p + String.fromCharCode(97 + (pass % 26));
    pass = pass / 26;
    if(pass < 1) {
      pass = Math.abs(sjcl.random.randomWords(1)[0]);
    }
  }
  return p;
}
function parseHash(hsh) {
  p = hsh.split("&");
  parms = {};
  for(i=0; i < p.length; i++) {
    kv = p[i].split("=")
    parms[kv[0]] = kv[1];
  }
  return parms;
}

function displayError() {
  setPasteto("Invalid key in url. Please make sure # parameter contains clef value");
}

var hljs_styles = ['github', 'googlecode', 'solarized_dark.dark', 'solarized_light', 'sunburst.dark'];

var parms = parseHash(window.location.hash.substr(1));
var password;

function wakeUp() {

  if(parms['clef']) {
    password = parms['clef'];
    var data = $('#encrypted').text();
    try {
      var ct = sjcl.decrypt(password, data);
      setPasteto(ct);
      $('#spare').text(ct);
    } catch(e) {
      if(e instanceof sjcl.exception.corrupt) {
        displayError();
      }
    } 
  }else {
    displayError();
  }


}
function RNGisReady() {
  $('#gl-but').removeAttr("disabled");
  $('#gl-text').text("");
}

if(encrypted) {
  $(document).ready(function() {wakeUp()});
}

$(document).ready(function() {
  sjcl.random.startCollectors();
  
  if(sjcl.random.isReady()) {
    RNGisReady();
  } else {
    sjcl.random.addEventListener("seeded", function(){
      RNGisReady();
    });
  }

  hljs_languages = Object.keys(hljs.LANGUAGES);
  $('#placeholder').replaceWith(function() {
    var o ='';
    for(i=0; i < hljs_languages.length; i++) {
      if(hljs_languages[i] == cur_lang)
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

  $("#gluu_form").submit(function () {
    var data = $("#clear_code").val();
    if(!sjcl.random.isReady())
    {
      alert("RNG not ready, move you mouse a bit and try again.");
      return false;
    }
    var password = generatePassword(16);

    encrypted = sjcl.encrypt(password, data);

    sent_data = { content: encrypted };

    var expiry;
    if($('#never_expire').is(':checked')) {
      sent_data['never_expire'] = true;
    } else {
      sent_data['expiry_delay'] = $('#expiry_delay').val();
    }

    $.ajax({
      type: "POST",
      url: "/paste",
      data: sent_data
    }).done(function( dest_url ) {
      document.location.href = dest_url + "#clef="+password;
    }).fail(function(jqXHR, textStatus) {
      console.log( "Request failed: " + textStatus );
    });

    return false;

  });

  var elt = $("#code")[0];
  if(elt) {
    hljs.highlightBlock(elt);

  }
  
  if(parms['lang']) {
    changeTo(parms['lang']);
  }
  if(parms['style']) {
    loadStyle(parms['style']);
  } else {
    silentLoadStyle('solarized_light');
  }

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

function setPasteto(content, lang) {
  var langClass = "";
  if(lang != undefined) {
    langClass = "class='"+lang+"'";
  }
  $('#code').replaceWith(function() {
    var c = $("<code id='code' "+langClass+"></code>");
    var lines = content.split(/\n/);
    for(var i=0; i < lines.length && i < 50; i++) {
      console.log(lines[i].length);
    }
    c.text(content);
    return c;
  });
  hljs.highlightBlock($('#code')[0]);

  if(lang == undefined) {
    var detected = $($("#code")[0]).attr('class');
    cur_lang = detected;
    $('#hljs_lang').text(detected);
  }
}

function changeTo(lang) {
  setPasteto($('#spare').text(), lang);
  $('#hljs_lang').text(lang);
  cur_lang = lang;
  updateHash();
}

