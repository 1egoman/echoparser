_ = require "underscore"
text_to_num = require 'text-to-number'

templ = require "./templ"

skill =
  name: "time"
  intents: [
    intent: "getCurrentTimeIntent"
    templ:
      where:
        type: String
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
      data: do (data) =>
        # coerse all data types to their proper values
        _.map int.templ, (v, k) =>

          # a number, but in a textual format (like fifty five)
          # this is converted back to its numerical representation (like 55)
          if typeof v.type(1) is "number" and k of data and isNaN parseFloat data[k]
            data[k] = text_to_num data[k]

          # manual coersion (like Number('5') for example)
          else if k of data
            data[k] = v.type(data[k])

          # not in the types list? remove it.
          else delete data[k]
        data
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
console.log get_matching_skills "what time is it in five", [skill]



# match the intent of a phrase
# console.log templ.embed("bla {abc}")(abc: "def")
