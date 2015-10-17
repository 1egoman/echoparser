$(document).ready(function() {
  $(".query-box").val(localStorage.phrase || '')
})

var interactionId = null;
var query = function(phrase, store) {
  if (localStorage && store !== false) localStorage.phrase = phrase

  // query the server
  $.ajax({
    type: "POST",
    url: "/api/v1/intent/"+(interactionId ? interactionId : ''),
    data: JSON.stringify({phrase: phrase}),
    headers: {"content-type": "application/json"},
    success: function(data) {
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
    }
  })
}
