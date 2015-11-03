$(document).ready(function() {
  $(".query-box").val(localStorage.phrase || '')
})

// websockets on port :7070 be default
ws = new WebSocket(location.href.replace(":7000", ":7070").replace("http://", "ws://"))


// listen for a websocket response
ws.onmessage = function(evt) {
  data = JSON.parse(evt.data)

  // store interaction location
  interactionId = data.interactionId

  // format list item
  listItem = "<li>"
  if (data.outputSpeach && data.outputSpeach.type === "PlainText") {
    listItem += "<h4>"+data.outputSpeach.text+"</h4>"
  }
  listItem += "<pre>"+JSON.stringify(data, null, 2)+"</pre>"

  // add as another item
  $("ul.intents").append(listItem+"</li>");

  // at the end of the interaction? Mention that too.
  if (data.shouldEndSession) {
    $("ul.intents").append("<li class='eoi'>End of Interaction</li>");
    interactionId = null
  }

  // hide spinner
  $(".spinner").css("display", "none")
}


var interactionId = null;
var query = function(phrase, store) {
  // show spinner
  $(".spinner").css("display", "block")

  // save phrase for next time
  if (localStorage && store !== false) localStorage.phrase = phrase

  // query the server
  ws.send(JSON.stringify({
    id: interactionId ? interactionId : undefined,
    phrase: phrase
  }))
}
