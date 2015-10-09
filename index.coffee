templ = require "./templ"

skill =
  name: "time"
  intents: [
    intent: "getCurrentTimeIntent"
    templ:
      hours:
        type: Number
    utterances: [
      "what time is it in {where}"
    ]
  ]


# match the intent of a phrase

console.log templ.embed("bla {abc}")(abc: "def")
