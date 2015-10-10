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
  intents = for int in skill.intents

    # get first truthy utterance (determine which utterance the user used)
    # TODO this could be made a lot more efficient
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


# iterate through a list of skills and only parse the elements that match
get_matching_skills = (text, skills) ->
  matches = for s in skills
    if match = extract_from_skill text, s
      name: s.name
      intent: match

  # if there are no matches, then return null. Otherwise,
  # compose the intent and skill name together and return the whole thing.
  matches.length is 0 and null or do (m=matches[0]) ->
    m.intent.name = "#{m.name}.#{m.intent.name}" # skill.intent
    m.intent

# test
console.log get_matching_skills "what time is it in london", [skill]



# match the intent of a phrase
# console.log templ.embed("bla {abc}")(abc: "def")
