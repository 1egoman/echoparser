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

# ------------------------------------------------------------------------------
# Some Additional Skill Types
# ------------------------------------------------------------------------------

# Only for adjusting something up or down (along one axis)
# responds to up, down, etc...
OneDimensRelativeDirection = (word) ->
  switch
    when word in ["up", "top", "increase", "upward"] then "up"
    when word in ["down", "bottom", "decrease", "downward"] then "down"
    else null

# Adjusting something in a 2 axis plane
# responds to up, down, left, right, etc...
RelativeDirection = (word) ->
  switch
    when word in ["up", "top", "increase", "upward"] then "up"
    when word in ["down", "bottom", "decrease", "downward"] then "down"
    when word in ["left", "bottom", "port", "leftward"] then "left"
    when word in ["left", "bottom", "starboard", "rightward"] then "left"
    else null

# adjust something absolutely
# responds to north, south, east, etc...
AbsoluteDirection = (word) ->
  switch
    when word in ["north"] then "north"
    when word in ["south"] then "south"
    when word in ["east"] then "east"
    when word in ["west"] then "west"
    else null
