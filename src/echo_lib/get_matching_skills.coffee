_ = require "underscore"
extract_from_skill  = require "./extract_from_skill"

# iterate through a list of skills and only parse the elements that match
module.exports = (text, skills) ->
  matches = _.compact(for s in skills
    if match = extract_from_skill text, s
      name: s.name
      intent: match
  )

  # if there are no matches, then return null. Otherwise,
  # compose the intent and skill name together and return the whole thing.
  if matches.length is 0
    null
  else
    do (m=matches[0]) ->
      m.intent.name = "#{m.name}.#{m.intent.name}" # skill.intent
      m.intent
