fs = require "fs"
{EventEmitter} = require "events"

class SkillList extends EventEmitter

  constructor: (@skills_file="./skills.json") -> @pull()

  # read skills from file and let others know about it
  pull: =>
    fs.readFile @skills_file, "UTF8", (err, data) =>
      if err
        @emit "error", err
      else
        @_skills = @unpack_intent_types JSON.parse data
        @emit "pull", @_skills

  skills: => @_skills

  # Convert string representations of types into the actual types
  # Within each type, we have something like "Number"
  # We need to convert that to Number (not a string, the global)
  unpack_intent_types: (skills) ->
    for s in skills
      for i in s.intents
        for k,v of i.templ
          if typeof v.type is "string"
            v.type = eval v.type # TODO better way to do this?
    skills

module.exports = SkillList
