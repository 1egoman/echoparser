fs = require "fs"
path = require "path"
async = require "async"
request = require "request"
{EventEmitter} = require "events"
Promise = require "promise"
chalk = require "chalk"

class SkillList extends EventEmitter

  constructor: (@skills_location="./skills", auto_pull=true) -> auto_pull and @pull()

  # read skills from file and let others know about it
  # FIXME how to test this?
  `/* istanbul ignore next */`
  pull: =>
    @_skills = []
    fs.readdir @skills_location, (err, skill_files) =>
      if err
        @emit "error", err
      else
        async.map skill_files.filter((f) -> f[0] isnt '.'), (skill, cb) =>
          skill_path = path.join @skills_location, skill
          skill_name = skill.replace(/\.[a-zA-Z]+/g, '')
          intent_path = path.resolve("src", "intent_handlers", skill_name)

          # does the intent path exist?
          # if not, let the user know
          try
            require intent_path
          catch
            console.warn chalk.yellow("-> Umm, no code behind `#{skill}` Add something to `intent_handlers`!")

          fs.readFile skill_path, "UTF8", (err, data) =>
            if err
              cb err
            else
              cb null, @unpack_intent_types @decode_skills data
        , (err, skills) =>
          if err
            @emit "error", err
          else
            @_skills = skills.reduce (all, s) -> (all or []).concat s
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

  # Convert skills format into JSON
  # skill.intentName
  #   utterance {foo}
  #   ---
  #   foo: String
  decode_skills: (raw) ->
    current_intent = null
    in_templ = false
    _skills = []

    raw.split('\n').forEach (ln, index) =>
      ln = ln.replace /[\s]+$/,'' # remote erronious whitespace on right (rtrim)
      switch

        # an intent definition
        when match = ln.match /(.+)\.(.+)/
          [_whole, skill, intent] = match
          skill_match = _skills.filter((s) -> s.name is skill)

          if skill_match.length is 0
            # add new skill
            _skills.push
              name: skill
              intents: [
                intent: intent
                utterances: []
                templ: []
              ]
            current_intent = _skills[_skills.length-1].intents[0]
            in_templ = false
          else
            # just add the intent
            skill_match[0].intents.push
              intent: intent
              utterances: []
              templ: []
            current_intent = skill_match[0].intents[skill_match[0].intents.length-1]
            in_templ = false


        # switch from utterances to templates
        when ln.match /[ ]+--[-]+/ then in_templ = true

        # an utterance
        when in_templ is false and match = ln.match /[  ]+(.*)/
          [_whole, utterance] = match
          current_intent.utterances.push utterance

        # a template
        when in_templ is true and match = ln.match /[ ]+([\w]+): ?([a-zA-Z]+)(?:[ ,]+([^\r\n]+))?/
          [_whole, name, type, metadata] = match

          # add the curly braces around the metadata json if needed
          metadata = "{#{metadata}}" if metadata and metadata[0] isnt '{'

          # try to parse the metadata
          try
            parse_meta = JSON.parse(metadata)
          catch
            current_intent.templ[name] = type: type
            break

          # otherwise, add the metadata in too
          current_intent.templ[name] =
            type: type
            metadata: parse_meta

    _skills




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

# Date time parser
# This is for a one-tim event, like 5:00pm
chrono = require "chrono-node"
When = (phrase) ->
  if date = chrono.parseDate phrase
    date
  else
    chrono.parseDate "in #{phrase}" # this makes the parser return a better result sometimes

# Date time parser
# This is for an event over a duration, like Sep 5-6
# chrono = require "chrono-node"
WhenDuration = (phrase) ->
  if date = chrono.parse phrase
    date
  else
    chrono.parse "in #{phrase}" # this makes the parser return a better result sometimes

# a place
# this will turn a place / location into an objecy containing:
# - the original phrase (raw)
# - the latitude (geo.lat)
# - the longitude (geo.lng)
Place = (phrase) ->
  new Promise (resolve, reject) ->
    if process.env.GOOGLE_MAPS_APP_GEOCODE_KEY

      # use the google maps geolocation api
      request """
      https://maps.googleapis.com/maps/api/geocode/json
      ?address=#{phrase}
      &key=#{process.env.GOOGLE_MAPS_APP_GEOCODE_KEY}
      """.replace(/[\n]/, '')
      , (err, resp, body) ->
        body = JSON.parse body

        if body.status is 'OK'
          results = body.results[0]
          resolve
            raw: phrase
            formatted: results.formatted_address
            geo: results.geometry.location
            body: body
        else
          resolve raw: phrase

    else
      reject "No Google Maps geolocation key provided. Please provide one in GOOGLE_MAPS_GEOCODE_KEY."
