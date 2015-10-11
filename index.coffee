_ = require "underscore"
text_to_num = require 'text-to-number'
templ = require "./templ"
skills = JSON.parse require("fs").readFileSync("./skills.json")

# Convert string representations of types into the actual types
for s in skills
  for i in s.intents
    for k,v of i.templ
      if typeof v.type is "string"
        v.type = eval v.type # TODO better way to do this?


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


    if data and Object.keys(data).length
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
  
  intents.length and _.compact(intents)[0] or null # return first element or null


# iterate through a list of skills and only parse the elements that match
get_matching_skills = (text, skills) ->
  matches = _.compact(for s in skills
    if match = extract_from_skill text, s
      name: s.name
      intent: match
  )


  # if there are no matches, then return null. Otherwise,
  # compose the intent and skill name together and return the whole thing.
  matches.length is 0 and null or do (m=matches[0]) ->
    m.intent.name = "#{m.name}.#{m.intent.name}" # skill.intent
    m.intent

# tell us that we'd like to respond to what the user said
# this is a helper to make the responses look good and easy for uesers to
# remember
form_response = (status, text, end_session=false) ->
  outputSpeech:
    type: "PlainText"
    text: text
  shouldEndSession: end_session

# run an example query
match_skill = get_matching_skills "what time is it in london", skills
switch match_skill.name

  # give a list of the numbers starting at n and going down by one
  when "repeat.repeatNumber"
    phrase = [0..match_skill.data.n].join ', '
    form_response true, phrase, true


