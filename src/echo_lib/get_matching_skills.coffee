_ = require "underscore"
extract_from_skill  = require "./extract_from_skill"
async = require "async"

# iterate through a list of skills and only parse the elements that match
module.exports = (text, skills, callback) ->
  count = 0

  async.map skills, (s, done) ->
    extract_from_skill text, s, (match) ->
      if match

        # if there are no matches, then return null. Otherwise,
        # compose the intent and skill name together and return the whole thing.
        callback do (match) ->
          match.name = "#{s.name}.#{match.name}" # skill.intent
          match

        # return an error to break out of the loop
        done true


      else
        count++
        done null
  , (err) ->
    # no matching skills
    if count >= skills.length
      callback null

