_ = require "underscore"
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

# given a skill and a phrase extract the data and the intent name
extract_from_skill = (text, skill) ->
  # for each intent, test whether the specified string matches
  intents = skill.intents.map (int) ->

    # get first truthy utterance (determine which utterance the user used)
    data = _.chain(int.utterances).map (utt) =>
      templ.extract(utt) text
    .find (a) => a
    .value()

    if data
      name: int.intent
      data: data
    else
      null
  
  intents.length and intents[0] or null # return first element or null



# test
console.log extract_from_skill "what time is it in london", skill



# match the intent of a phrase
# console.log templ.embed("bla {abc}")(abc: "def")
